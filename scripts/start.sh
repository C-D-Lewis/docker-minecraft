#!/bin/bash

set -eu

MEMORY=$(cat ./config.json | jq -r ".MEMORY")
PORT=$(cat ./config.json | jq -r ".PORT")

java -Xmx$MEMORY -Xms$MEMORY -jar server.jar nogui --port $PORT
