#!/bin/bash

set -eu

CONFIG_NAME=$1

NAME=$(cat ./config.json | jq -r ".NAME")

# Build the image
docker build -t $NAME . --build-arg CONFIG=$CONFIG_NAME

# Make sure the world directory exists to mount and persist to
mkdir -p world

# Run the image with exposed port and mounted world directory
docker run --rm -p 25565:25565 -v ./world:/server/world -t $NAME
