#!/bin/bash

set -eu

JAVA_VERSION=$1

PLATFORM=$(uname -a)

if [[ "$PLATFORM" =~ "aarch64" ]]; then
  echo ">>> Platform is aarch64"
  file="openjdk-$JAVA_VERSION-linux-aarch64_bin.tar.gz"
else
  echo ">>> Platform is other ($PLATFORM)"
  file="openjdk-$JAVA_VERSION-linux-x64_bin.tar.gz"
fi

echo ">>> Downloading $file"
curl "https://s3.amazonaws.com/public-files.chrislewis.me.uk/infra/$file" -o java.tar.gz -sS --fail-with-body

tar -xzf java.tar.gz -C /opt

update-alternatives --install /usr/bin/java java /opt/jdk-$JAVA_VERSION/bin/java 1

rm java.tar.gz
