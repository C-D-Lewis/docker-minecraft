#!/bin/bash

set -eu

SERVER_NAME=$1
USR=$2

if [ ! -d "./config/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi
S3_BACKUP_DIR=$(cat ./config/$SERVER_NAME/config.json | jq -r ".S3_BACKUP_DIR")

DATE=$(TZ=GMT date +"%Y%m%d")
OUTPUT_FILE="$SERVER_NAME-$DATE.zip"

# Allow sudo crontab to find ~/.aws/
export HOME="${HOME:=/home/$USR}"

./scripts/create-zip.sh $USR
mv "backup.zip" "$OUTPUT_FILE"

echo ">>> Uploading to $S3_BACKUP_DIR"
/usr/local/bin/aws s3 cp $OUTPUT_FILE "$S3_BACKUP_DIR/"

echo ">>> Copying to latest"
/usr/local/bin/aws s3 cp "$S3_BACKUP_DIR/$OUTPUT_FILE" "$S3_BACKUP_DIR/$SERVER_NAME-latest.zip"

echo ">>> Cleaning up"
rm -rf $OUTPUT_FILE

echo "$(date)" >> upload-backup.log
echo ">>> Complete"
