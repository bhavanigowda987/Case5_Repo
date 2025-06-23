#!/bin/bash
THRESHOLD_DATE=$(date -d '14 days ago' +%Y-%m-%d)

aws ec2 describe-snapshots --owner-ids self | jq -r \
  --arg d "$THRESHOLD_DATE" \
  '.Snapshots[] | select(.StartTime < $d) | .SnapshotId' | while read SNAP_ID; do
    echo "Deleting snapshot: $SNAP_ID"
    aws ec2 delete-snapshot --snapshot-id $SNAP_ID
done
