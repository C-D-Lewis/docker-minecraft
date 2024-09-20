#!/bin/bash

set -eu

SERVER_NAME=$1

S3_BACKUP_DIR=$(cat ./config/$SERVER_NAME/config.json | jq -r ".S3_BACKUP_DIR")

read -p "WARNING: This will erase local world directory and replace with latest from S3 (y/n)?" CONT
if [ "$CONT" != "y" ]; then
  exit 0
fi

echo ">>> Erasing world"
rm -rf ./world

echo ">>> Downloading from S3"
/usr/local/bin/aws s3 cp "$S3_BACKUP_DIR/$SERVER_NAME-latest.zip" .

echo ">>> Unzipping world"
unzip $SERVER_NAME-latest.zip -d ./temp
mv ./temp/world .

echo ">>> Cleaning up"
rm -rf ./temp
rm $SERVER_NAME-latest.zip

echo ">>> Complete"
