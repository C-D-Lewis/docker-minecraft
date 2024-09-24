#!/bin/bash

set -eu

USR=$1
SERVER_NAME=$2

if [ ! -d "./config/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi
LOCAL_BACKUP_DIR=$(cat ./config/$SERVER_NAME/config.json | jq -r ".LOCAL_BACKUP_DIR")

DAY_OF_WEEK=$(date +'%A')
OUTPUT_FILE="$SERVER_NAME-$DAY_OF_WEEK.zip"
OUTPUT_PATH="$LOCAL_BACKUP_DIR/$OUTPUT_FILE"

# Server must be running successfully
# if pgrep -x java > /dev/null
# then
#   sleep 1
# else
#   echo ">>> java is not running, world might not be launchable"
#   exit 1
# fi

./scripts/create-zip.sh $USR

echo ">>> Moving to $OUTPUT_PATH"
mv backup.zip $OUTPUT_PATH

echo "$(date)" >> local-backup.log
echo ">>> Complete"
