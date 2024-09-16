#!/bin/bash

set -eu

USR=$1
SERVER_NAME=$2
S3_BUCKET_DIR=$3

DATE=$(TZ=GMT date +"%Y%m%d")
OUTPUT_FILE="$SERVER_NAME-$DATE.zip"

# Allow sudo crontab to find ~/.aws/
export HOME="${HOME:=/home/$USR}"

# Server must be running successfully
# if pgrep -x java >/dev/null
# then
#   sleep 1
# else
#   echo ">>> java is not running, world might not be launchable"
#   exit 1
# fi

./scripts/create-zip.sh $USR
mv "backup.zip" "$OUTPUT_FILE"

echo ">>> Uploading"
/usr/local/bin/aws s3 cp $OUTPUT_FILE "$S3_BUCKET_DIR/"

echo ">>> Copying to latest"
/usr/local/bin/aws s3 cp "$S3_BUCKET_DIR/$OUTPUT_FILE" "$S3_BUCKET_DIR/$SERVER_NAME-latest.zip"

echo ">>> Cleaning up"
rm -rf $OUTPUT_FILE

echo "$(date)" >> upload-backup.log
echo ">>> Complete"