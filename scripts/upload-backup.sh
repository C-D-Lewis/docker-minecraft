#!/bin/bash

# Needs to be run with 'sudo -E' to preserve AWS env vars and set perms

set -eu

SERVER_NAME=$1
USR=$2

# Allow sudo crontab to find ~/.aws/
export HOME="${HOME:=/home/$USR}"

DATE=$(TZ=GMT date +"%Y%m%d")
OUTPUT_FILE="$SERVER_NAME-$DATE.zip"
EFS_DIR=/var/data/efs
AWS_BIN=$(which aws || echo "/usr/local/bin/aws")

if [ ! -d "./config/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi
S3_BACKUP_DIR=$(cat ./config/$SERVER_NAME/config.json | jq -r ".S3_BACKUP_DIR")
ON_AWS=$(cat ./config/$SERVER_NAME/config.json | jq -r ".ON_AWS")

# Using EFS for backup, need to restore symlinks in Fargate task
if [[ $ON_AWS == "true" ]]; then
  for DIR in world world_nether world_the_end plugins; do
    # Create symlink in this instance
    if [[ ! -d "$DIR" ]]; then
      ln -s "$EFS_DIR/$DIR" "$DIR"
      echo ">>> Created symlink $DIR -> $EFS_DIR/$DIR"
    fi
  done
fi

echo ">>> Creating backup for $SERVER_NAME"
./scripts/create-zip.sh $USR

echo ">>> Uploading to $S3_BACKUP_DIR"
mv "backup.zip" "$OUTPUT_FILE"
$AWS_BIN s3 cp $OUTPUT_FILE "$S3_BACKUP_DIR/"

echo ">>> Copying to latest"
$AWS_BIN s3 cp "$S3_BACKUP_DIR/$OUTPUT_FILE" "$S3_BACKUP_DIR/$SERVER_NAME-latest.zip"

echo ">>> Cleaning up"
rm -rf $OUTPUT_FILE

echo "$(date)" >> upload-backup.log
echo ">>> Complete"
