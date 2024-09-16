#!/bin/bash

set -eu

USR=$1
BACKUP_DIR=$2

DAY_OF_WEEK=$(date +'%A')
OUTPUT_FILE="backup-$DAY_OF_WEEK.zip"

# Server must be running successfully
# if pgrep -x java > /dev/null
# then
#   sleep 1
# else
#   echo ">>> java is not running, world might not be launchable"
#   exit 1
# fi

./scripts/create-zip.sh $USR

echo ">>> Moving"
mv backup.zip "$BACKUP_DIR/$OUTPUT_FILE"

echo "$(date)" >> local-backup.log
echo ">>> Complete"
