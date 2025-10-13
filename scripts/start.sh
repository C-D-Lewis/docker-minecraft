#!/bin/bash

set -eu

EFS_DIR=/var/data/efs

MEMORY=$(cat ./config.json | jq -r ".MEMORY")
PORT=$(cat ./config.json | jq -r ".PORT")
SERVER_NAME=$(cat ./config.json | jq -r ".SERVER_NAME")
ON_AWS=$(cat ./config.json | jq -r ".ON_AWS")

first_launch="false"

if [[ $ON_AWS == "true" ]]; then
  # Start simple web server for health check
  python3 -m http.server 80 --directory "$EFS_DIR" &

  # HACK for frest start DO NOT COMMIT ENABLED
  # rm -rf /var/data/efs/*

  # Symlink world dirs to /var/data/efs
  # NOTE: This dir list works for vanilla and PaperMC, but may not for others
  for DIR in world world_nether world_the_end plugins; do
    # Create in EFS if doesn't exist
    if [[ ! -d "$EFS_DIR/$DIR" ]]; then
      mkdir -p "$EFS_DIR/$DIR"

      echo ">>> Created $EFS_DIR/$DIR"
      first_launch="true"
    else
      echo ">>> Found existing $EFS_DIR/$DIR"
      ls -lh "$EFS_DIR/$DIR"
    fi
    # Create symlink in this instance
    if [[ ! -d "$DIR" ]]; then
      ln -s "$EFS_DIR/$DIR" "$DIR"
      echo ">>> Created symlink $DIR -> $EFS_DIR/$DIR"
    fi
  done

  if [[ $first_launch == "true" ]]; then
    echo ">>> First launch - fetching latest world from S3"
    # Fetch latest world - need AWS CLI and script updated for right binary
    ./scripts/fetch-latest-world.sh $SERVER_NAME
  fi

  # Print contents of EFS dir for debugging
  echo ">>> EFS contents:"
  du -h -d 1 $EFS_DIR
fi

java -Xmx$MEMORY -Xms$MEMORY -jar server.jar nogui --port $PORT
