#!/bin/bash

set -eu

USR=$1

OUT_DIR="/mnt/ssd/backup/"
DAY_OF_WEEK=$(date +'%A')
OUTPUT_FILE="docker-minecraft-$DAY_OF_WEEK.zip"

# Server must be running successfully
if pgrep -x java > /dev/null
then
  sleep 1
else
  echo ">>> java is not running, world might not be launchable"
  exit 1
fi

./scripts/create-zip.sh $USR
mv "docker-minecraft.zip" "$OUTPUT_FILE"

echo ">>> Moving"
mkdir -p backups
rsync --progress $OUTPUT_FILE ./backups/

echo "$(date)" >> local-backup.log
echo ">>> Complete"
