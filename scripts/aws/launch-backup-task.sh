#!/bin/bash

set -eu

SERVER_NAME=$1

# Project name
PROJECT_NAME="dkr-mc-$SERVER_NAME"

# Must match the main.tf region
export AWS_DEFAULT_REGION=eu-west-2

echo ">>> Fetching required resources..."

# Get security group
RES=$(aws ec2 describe-security-groups --filters "Name=group-name,Values=$PROJECT_NAME-sg")
SECURITY_GROUP_ID=$(echo $RES | jq -r '.SecurityGroups[0].GroupId')

# Get VPC (assuming only one)
RES=$(aws ec2 describe-vpcs)
VPC_ID=$(echo $RES | jq -r '.Vpcs[0].VpcId')

# Get subnets (assume all are public)
RES=$(aws ec2 describe-subnets --filters "Name=vpc-id,Values=$VPC_ID")
SUBNET_ID=$(echo $RES | jq -r '.Subnets[0].SubnetId')

# Create a Fargate task
echo ">>> Creating task..."
RES=$(aws ecs run-task \
  --cluster $PROJECT_NAME-cluster \
  --task-definition $PROJECT_NAME-td \
  --count 1 \
  --launch-type FARGATE \
  --network-configuration "{
    \"awsvpcConfiguration\": {
      \"subnets\": [\"$SUBNET_ID\"],
      \"securityGroups\": [\"$SECURITY_GROUP_ID\"],
      \"assignPublicIp\": \"ENABLED\"
    }
  }" \
  --overrides "{
    \"containerOverrides\": [{
      \"name\": \"$PROJECT_NAME-container\",
      \"command\": [\"/bin/sh\", \"-c\", \"/server/scripts/upload-backup.sh $SERVER_NAME root true\"]
    }]
  }" \
)

TASK_ID=$(echo $RES | jq -r '.tasks[0].taskArn')
echo ">>> Started: $TASK_ID"
echo ""

watch ./scripts/aws/get-tasks.sh $SERVER_NAME
