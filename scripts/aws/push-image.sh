#!/bin/bash

set -eu

SERVER_NAME=$1
if [ ! -d "./servers/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi

ECR_NAME="dkr-mc-$SERVER_NAME-ecr"
IMAGE_NAME="docker-minecraft"
REGION="eu-west-2"

# Build the image
docker build -t $IMAGE_NAME . --build-arg SERVER_NAME=$SERVER_NAME --build-arg ON_AWS=true

# Get details
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com
RES=$(aws ecr describe-repositories --region $REGION --repository-names $ECR_NAME)
ECR_URI="$(echo $RES | jq -r '.repositories[0].repositoryUri')"

# Tag and push image to ECR
TARGET="$ECR_URI:latest"
docker tag $IMAGE_NAME $TARGET
docker push $TARGET
