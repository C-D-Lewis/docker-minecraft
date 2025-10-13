#!/bin/bash

set -eu

SERVER_NAME=$1
if [ ! -d "./config/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi

# Deploy infrastructure
echo ">>> Deploying infrastructure"
cd terraform
terraform init -reconfigure
terraform apply -var "server_name=$SERVER_NAME"

# Push image
cd ..
echo ">>> Pushing image to AWS ECR"
./scripts/aws/push-image.sh $SERVER_NAME

# Watch for image
watch ./scripts/aws/get-tasks.sh $SERVER_NAME
