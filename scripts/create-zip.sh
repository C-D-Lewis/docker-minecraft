#!/bin/bash

# Should be run as sudo for ownership fixes (assuming RPi user 'pi')

set -eu

USR=$1

OUTPUT_FILE="docker-minecraft.zip"

echo ">>> Removing zips"
rm -rf ./*.zip

echo ">>> Updating ownership"
chown -R $USR ./

echo ">>> Creating zip"
zip -r $OUTPUT_FILE .

size=$(stat -c '%s' $OUTPUT_FILE | numfmt --to=si --suffix=B)
echo ">>> Size: $size"
