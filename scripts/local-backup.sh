#!/bin/bash

set -eu

SERVER_NAME=$1
USR=$2

if [ ! -d "./config/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi
LOCAL_BACKUP_DIR=$(cat ./config/$SERVER_NAME/config.json | jq -r ".LOCAL_BACKUP_DIR")

DAY_OF_WEEK=$(date +'%A')
OUTPUT_FILE="$SERVER_NAME-$DAY_OF_WEEK.zip"
OUTPUT_PATH="$LOCAL_BACKUP_DIR/$OUTPUT_FILE"

./scripts/create-zip.sh $USR

echo ">>> Moving to $OUTPUT_PATH"
mv backup.zip $OUTPUT_PATH

echo "$(date)" >> local-backup.log
echo ">>> Complete"
