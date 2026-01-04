#!/bin/bash

set -eu

# Must match main.tf
export AWS_DEFAULT_REGION="eu-west-2"

SERVER_NAME=$1

if [ ! -d "./servers/$SERVER_NAME" ]; then
  echo "Invalid SERVER_NAME"
  exit 1
fi

# Project name
PROJECT_NAME="dkr-mc-$SERVER_NAME"
# Cluster name
CLUSTER_NAME="$PROJECT_NAME-cluster"

task_list=$(aws ecs list-tasks --cluster $CLUSTER_NAME --query 'taskArns[]' --output text)
if [ -z "$task_list" ]; then
  echo "No tasks found in cluster $CLUSTER_NAME"
  exit 0
fi
echo "Tasks in cluster $CLUSTER_NAME:"
echo "$task_list"
echo ""

aws ecs describe-tasks \
  --cluster $CLUSTER_NAME \
  --tasks $task_list \
  --query 'tasks[*].[taskArn, lastStatus]' \
  --output table
