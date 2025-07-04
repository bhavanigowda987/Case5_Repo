#!/bin/bash

BUCKET="cs5-shared-bucket"
OUT_FOLDER="out"
COUNT_FOLDER="count"
TMP_DIR="/tmp"

aws s3 ls s3://$BUCKET/$OUT_FOLDER/ | awk '{print $4}' | while read file; do
  if [[ $file == *.txt ]]; then
    aws s3 cp s3://$BUCKET/$OUT_FOLDER/$file $TMP_DIR/$file
    word_count=$(wc -w < $TMP_DIR/$file)
    date_stamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo "File: $file | Words: $word_count | Date: $date_stamp" >> $TMP_DIR/count.txt
  fi
done

aws s3 cp $TMP_DIR/count.txt s3://$BUCKET/$COUNT_FOLDER/count.txt
