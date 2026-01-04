#!/bin/bash

set -eu

SERVER_NAME=$1

if [ ! -d "./servers/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi
PORT=$(cat ./servers/$SERVER_NAME/config.json | jq -r ".PORT")
DYNMAP_PORT=$(cat ./servers/$SERVER_NAME/config.json | jq -r ".DYNMAP_PORT")

# Make sure the world directory exists to mount and persist to
# Also make libraries dir in case a modded server uses it (Dockerfile expects it)
mkdir -p world libraries

# Build the image
docker build -t $SERVER_NAME . --build-arg SERVER_NAME=$SERVER_NAME

# Run the image with exposed:
# - Minecraft server port
# - Dynmap port (if specified)
# - Mounted world directory (some for Spigot servers too)
# - Any spigot plugins and associated data
docker run --rm \
  --name $SERVER_NAME \
  -p $PORT:$PORT \
  $(if [[ -n "$DYNMAP_PORT" && ${#DYNMAP_PORT} -gt 0 ]]; then echo "-p $DYNMAP_PORT:$DYNMAP_PORT"; fi) \
  -v ./world:/server/world \
  -v ./world_nether:/server/world_nether \
  -v ./world_the_end:/server/world_the_end \
  -v ./servers/$SERVER_NAME/plugins:/server/plugins \
  -t $SERVER_NAME 2>&1 | tee docker-minecraft.log
