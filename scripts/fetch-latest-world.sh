#!/bin/bash

set -eu

SERVER_NAME=$1

ON_AWS=$(cat ./config/$SERVER_NAME/config.json | jq -r ".ON_AWS")

if [[ $ON_AWS != "true" ]]; then
  if [ ! -d "./config/$SERVER_NAME" ]; then
    echo "Invalid SERVER_NAME"
    exit 1
  fi
fi
S3_BACKUP_DIR=$(cat ./config/$SERVER_NAME/config.json | jq -r ".S3_BACKUP_DIR")

# Only prompt if not on AWS
if [ $ON_AWS != "true" ]; then
  read -p "WARNING: This will erase local world directory and replace with latest from S3 (y/n)?" CONT
  if [ "$CONT" != "y" ]; then
    exit 0
  fi

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
mkdir -p ./world || true
mkdir -p ./world_nether || true
mkdir -p ./world_the_end || true
cp -r ./temp/world/* ./world/ || true
cp -r ./temp/world_nether/* ./world_nether/ || true
cp -r ./temp/world_the_end/* ./world_the_end/ || true

echo ">>> Copying plugin data"
if [ $ON_AWS == "true" ]; then
  cp -r "./temp/config/$SERVER_NAME/plugins" "/var/data/efs/" || true
else
  cp -r "./temp/config/$SERVER_NAME/plugins" "./config/$SERVER_NAME/" || true
fi

echo ">>> Cleaning up"
rm -rf ./temp
#rm $SERVER_NAME-latest.zip

echo ">>> Complete"
