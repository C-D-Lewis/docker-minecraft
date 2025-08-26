#!/bin/bash

set -eu

ECR_NAME="docker-minecraft-ecr"
IMAGE_NAME="docker-minecraft"

SERVER_NAME=$1

if [ ! -d "./config/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi

# Build the image
docker build -t $IMAGE_NAME . --build-arg CONFIG=$SERVER_NAME

# Get details
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com
RES=$(aws ecr describe-repositories --region us-east-1 --repository-names $ECR_NAME)
ECR_URI="$(echo $RES | jq -r '.repositories[0].repositoryUri')"

# Tag and push image to ECR
TARGET="$ECR_URI:latest"
docker tag $IMAGE_NAME $TARGET
docker push $TARGET
