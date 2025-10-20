#!/bin/bash

set -eu

JAR=$(cat ./config.json | jq -r ".JAR")

if [ -z "$JAR" ]; then
  echo "No JAR specified in config.json, assuming it already exists as the only jar"
  exit 0
fi

curl "https://s3.amazonaws.com/public-files.chrislewis.me.uk/infra/$JAR" -o server.jar
