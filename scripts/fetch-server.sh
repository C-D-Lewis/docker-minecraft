#!/bin/bash

set -eu

JAR=$(cat ./config.json | jq -r ".JAR")

curl "https://s3.amazonaws.com/public-files.chrislewis.me.uk/infra/$JAR" -o server.jar
