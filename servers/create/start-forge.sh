#!/usr/bin/env sh

set -eu

PORT=$(cat ./config.json | jq -r ".PORT")
MEMORY=$(cat ./config.json | jq -r ".MEMORY")

# Forge requires a configured set of both JVM and program arguments.
# Add custom JVM arguments to the user_jvm_args.txt
# Add custom program arguments {such as nogui} to this file in the next line before the "$@" or
#  pass them to this script directly
java -Xmx$MEMORY -Xms$MEMORY @libraries/net/minecraftforge/forge/1.20.1-47.4.0/unix_args.txt nogui --port $PORT
