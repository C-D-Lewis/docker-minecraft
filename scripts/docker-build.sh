#!/bin/bash

set -eu

SERVER_NAME=$1

if [ ! -d "./servers/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi
JAVA_VERSION=$(cat ./servers/$SERVER_NAME/config.json | jq -r ".JAVA_VERSION")

# Do the build!
docker build -t $SERVER_NAME . \
  --build-arg SERVER_NAME=$SERVER_NAME \
  --build-arg JAVA_VERSION=$JAVA_VERSION

echo ">>> Docker build complete"
