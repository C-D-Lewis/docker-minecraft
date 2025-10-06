#!/bin/bash

set -eu

SERVER_NAME=$1
ON_AWS=$2

# Only validate if not on AWS 
if [[ $ON_AWS != "confirm" ]]; then
  if [ ! -d "./config/$SERVER_NAME" ]; then
    echo "Invalid SERVER_NAME"
    exit 1
  fi
fi
S3_BACKUP_DIR=$(cat ./config/$SERVER_NAME/config.json | jq -r ".S3_BACKUP_DIR")

# Only prompt if not bypassing
if [ $ON_AWS != 'confirm' ]; then
  read -p "WARNING: This will erase local world directory and replace with latest from S3 (y/n)?" CONT
  if [ "$CONT" != "y" ]; then
    exit 0
  fi
fi

# Only erase if not bypassing (on AWS)
if [ $ON_AWS != 'confirm' ]; then
  echo ">>> Erasing worlds"
  rm -rf ./world
  rm -rf ./world_nether
  rm -rf ./world_the_end
fi

echo ">>> Downloading from S3"
$(which aws) s3 cp "$S3_BACKUP_DIR/$SERVER_NAME-latest.zip" .

echo ">>> Unzipping world"
unzip $SERVER_NAME-latest.zip -d ./temp

echo ">>> Copying worlds"
# Handle AWS case where these are symlinks and already exist
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
