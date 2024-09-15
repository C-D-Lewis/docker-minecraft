#!/bin/bash

set -eu

VERSION=$(cat ./config.json | jq -r ".VERSION")

curl "https://s3.amazonaws.com/public-files.chrislewis.me.uk/infra/minecraft-server_$VERSION.jar" -o server.jar
