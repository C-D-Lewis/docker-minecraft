#!/bin/bash

set -eu

if [[ $(uname -a) =~ "aarch64" ]]; then
  echo ">>> Platform is aarch64"
  file="openjdk-22.0.2_linux-aarch64_bin.tar.gz"
else
  echo ">>> Platform is other"
  file="openjdk-22.0.2_linux-x64_bin.tar.gz"
fi

curl "https://s3.amazonaws.com/public-files.chrislewis.me.uk/infra/$file" -o java.tar.gz
