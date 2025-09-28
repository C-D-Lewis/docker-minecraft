#!/bin/bash

set -eu

EFS_DIR=/var/data/efs

MEMORY=$(cat ./config.json | jq -r ".MEMORY")
PORT=$(cat ./config.json | jq -r ".PORT")
USE_EFT=$(cat ./config.json | jq -r ".USE_EFS")

# Symlink world dirs to /var/data/efs
if [[ -n $USE_EFS ]]; then
  for DIR in world world_nether world_the_end; do
    # Create if doesn't exist
    if [[ ! -d "$EFS_DIR/$DIR" ]]; then
      mkdir -p "$EFS_DIR/$DIR"
    fi

    ln -s "$EFS_DIR/$DIR" "$DIR"
  done
fi

java -Xmx$MEMORY -Xms$MEMORY -jar server.jar nogui --port $PORT
