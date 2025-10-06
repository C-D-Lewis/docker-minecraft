#!/bin/bash

set -eu

PLATFORM=$(uname -a)

if [[ "$PLATFORM" =~ "aarch64" ]]; then
  echo ">>> Platform is aarch64"
  file="openjdk-22.0.2_linux-aarch64_bin.tar.gz"
else
  echo ">>> Platform is other ($PLATFORM)"
  file="openjdk-22.0.2_linux-x64_bin.tar.gz"
fi

curl "https://s3.amazonaws.com/public-files.chrislewis.me.uk/infra/$file" -o java.tar.gz

tar -xzf java.tar.gz

update-alternatives --install /usr/bin/java java /opt/jdk-22.0.2/bin/java 1

rm java.tar.gz
