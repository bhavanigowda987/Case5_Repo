#!/bin/bash
yum update -y
yum install -y aws-cli jq cronie
systemctl enable crond
systemctl start crond

mkdir -p /opt/case-study/scripts

# Download your scripts from S3 or use inline heredoc (for demo simplicity, inline here)
cat << 'EOF' > /opt/case-study/scripts/word_count.sh
#!/bin/bash
BUCKET="case5-bucket"
OUT_FOLDER="out"
COUNT_FOLDER="count"
TMP_DIR="/tmp"

aws s3 ls s3://$BUCKET/$OUT_FOLDER/ | awk '{print \$4}' | while read file; do
  if [[ \$file == *.txt ]]; then
    aws s3 cp s3://\$BUCKET/\$OUT_FOLDER/\$file \$TMP_DIR/\$file
    word_count=\$(wc -w < \$TMP_DIR/\$file)
    date_stamp=\$(date "+%Y-%m-%d %H:%M:%S")
    echo "File: \$file | Words: \$word_count | Date: \$date_stamp" >> \$TMP_DIR/count.txt
  fi
done

aws s3 cp \$TMP_DIR/count.txt s3://\$BUCKET/\$COUNT_FOLDER/count.txt
EOF

cat << 'EOF' > /opt/case-study/scripts/ec2_start.sh
#!/bin/bash
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
aws ec2 start-instances --instance-ids \$INSTANCE_ID --region us-west-1
EOF

cat << 'EOF' > /opt/case-study/scripts/ec2_stop.sh
#!/bin/bash
INSTANCE_ID="$(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
aws ec2 stop-instances --instance-ids \$INSTANCE_ID --region us-west-1
EOF

cat << 'EOF' > /opt/case-study/scripts/delete_old_snapshots.sh
#!/bin/bash
THRESHOLD_DATE=\$(date -d '14 days ago' +%Y-%m-%d)

aws ec2 describe-snapshots --owner-ids self | jq -r \
  --arg d "\$THRESHOLD_DATE" \
  '.Snapshots[] | select(.StartTime < \$d) | .SnapshotId' | while read SNAP_ID; do
    echo "Deleting snapshot: \$SNAP_ID"
    aws ec2 delete-snapshot --snapshot-id \$SNAP_ID
done
EOF

# Make scripts executable
chmod +x /opt/case-study/scripts/*.sh

# Setup crontab
cat << 'EOF' > /etc/cron.d/case-study-jobs
*/15 * * * * ec2-user /opt/case-study/scripts/word_count.sh
0 18 * * * ec2-user /opt/case-study/scripts/ec2_stop.sh
0 21 * * * ec2-user /opt/case-study/scripts/ec2_start.sh
0 0 * * 0 ec2-user /opt/case-study/scripts/delete_old_snapshots.sh
EOF

chmod 0644 /etc/cron.d/case-study-jobs
