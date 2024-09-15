#!/bin/bash

set -eu

MEMORY=$(cat ./config.json | jq -r ".MEMORY")

java -Xmx$MEMORY -Xms$MEMORY -jar server.jar nogui
