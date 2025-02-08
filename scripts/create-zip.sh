#!/bin/bash

# Should be run as sudo for ownership fixes

set -eu

USR=$1

OUTPUT_FILE="backup.zip"

echo ">>> Removing existing backup"
rm -rf "./$OUTPUT_FILE"

echo ">>> Updating ownership"
chown -R $USR ./

echo ">>> Creating zip"
zip -r $OUTPUT_FILE . \
  --exclude "*node_modules*" \
  --exclude "*backups*" \
  --exclude "*spark*"  \
  --exclude "*plugins/dynmap/web/tiles*" \
  --exclude "./*.zip"

size=$(stat -c '%s' $OUTPUT_FILE | numfmt --to=si --suffix=B)
echo ">>> Size: $size"
