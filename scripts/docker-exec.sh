#!/bin/bash

set -eu

SERVER_NAME=$1

if [ ! -d "./servers/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi

# Get container ID
CONTAINER_ID=$(docker ps -aqf "name=$SERVER_NAME")

# Exec it
echo ">>> exec container '$CONTAINER_ID' with name '$SERVER_NAME'"
docker exec -t -i $CONTAINER_ID /bin/bash
