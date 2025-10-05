#!/bin/bash

set -eu

SERVER_NAME=$1
CONFIRM=$2

if [[ $CONFIRM != "confirm" ]]; then
  # Only validate if not in pre-built image environment
  if [ ! -d "./config/$SERVER_NAME" ]; then
    echo "Invalid SERVER_NAME"
    exit 1
  fi
fi
S3_BACKUP_DIR=$(cat ./config/$SERVER_NAME/config.json | jq -r ".S3_BACKUP_DIR")

if [ $CONFIRM != 'confirm' ]; then
  read -p "WARNING: This will erase local world directory and replace with latest from S3 (y/n)?" CONT
  if [ "$CONT" != "y" ]; then
    exit 0
  fi
fi

echo ">>> Erasing world"
rm -rf ./world

echo ">>> Downloading from S3"
$(which aws) s3 cp "$S3_BACKUP_DIR/$SERVER_NAME-latest.zip" .

echo ">>> Unzipping world"
unzip $SERVER_NAME-latest.zip -d ./temp

echo ">>> Copying worlds"
# Hanle AWS case where these are symlinks
mkdir -p ./world || true
mkdir -p ./world_nether || true
mkdir -p ./world_the_end || true
cp -r ./temp/world/* ./world/ || true
cp -r ./temp/world_nether/* ./world_nether/ || true
cp -r ./temp/world_the_end/* ./world_the_end/ || true

echo ">>> Copying plugin data"
cp -r "./temp/config/$SERVER_NAME/plugins" "./config/$SERVER_NAME/" || true

echo ">>> Cleaning up"
rm -rf ./temp
#rm $SERVER_NAME-latest.zip

echo ">>> Complete"
