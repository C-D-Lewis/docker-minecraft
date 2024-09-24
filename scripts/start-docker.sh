#!/bin/bash

set -eu

SERVER_NAME=$1

if [ ! -d "./config/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi
PORT=$(cat ./config/$SERVER_NAME/config.json | jq -r ".PORT")

# Build the image
docker build -t $SERVER_NAME . --build-arg CONFIG=$SERVER_NAME

# Make sure the world directory exists to mount and persist to
mkdir -p world

# Run the image with exposed:
# - Minecraft server port
# - Dynmap port
# - Mounted world directory (some for Spigot servers too)
# - Any spigot plugins and associated data
docker run --rm \
  -p $PORT:$PORT \
  -p 8123:8123 \
  -v ./world:/server/world \
  -v ./world_nether:/server/world_nether \
  -v ./world_the_end:/server/world_the_end \
  -v ./config/$SERVER_NAME/plugins:/server/plugins \
  -t $SERVER_NAME
