#!/bin/bash

set -eu

SERVER_NAME=$1

if [ ! -d "./config/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi
PORT=$(cat ./config/$SERVER_NAME/config.json | jq -r ".PORT")
DYNMAP_PORT=$(cat ./config/$SERVER_NAME/config.json | jq -r ".DYNMAP_PORT")

# Build the image
docker build -t $SERVER_NAME . --build-arg CONFIG=$SERVER_NAME

# Make sure the world directory exists to mount and persist to
mkdir -p world

# Run the image with exposed:
# - Minecraft server port
# - HTTP port for health checks
# - Dynmap port (if specified)
# - Mounted world directory (some for Spigot servers too)
# - Any spigot plugins and associated data
docker run --rm \
  --name $SERVER_NAME \
  -p $PORT:$PORT \
  -p 80:80 \
  $(if [[ -n "$DYNMAP_PORT" && ${#DYNMAP_PORT} -gt 0 ]]; then echo "-p $DYNMAP_PORT:$DYNMAP_PORT"; fi) \
  -v ./world:/server/world \
  -v ./world_nether:/server/world_nether \
  -v ./world_the_end:/server/world_the_end \
  -v ./config/$SERVER_NAME/plugins:/server/plugins \
  -t $SERVER_NAME 2>&1 | tee docker-minecraft.log
