#!/bin/bash

# VALIDATING CLOUDFORMATION YAML SYNTAX
echo "[deploy-ecs-cluster] Validating CloudFormation yaml syntax..."
# https://docs.aws.amazon.com/cli/latest/reference/cloudformation/validate-template.html#examples
aws cloudformation validate-template --template-body file://$INFRASTRUCTURE_FOLDER/01-vpc.yml  > /dev/null
aws cloudformation validate-template --template-body file://$INFRASTRUCTURE_FOLDER/02-ecs.yml  > /dev/null
# Disabled due not present by default in aws cli
# https://github.com/aws-cloudformation/cfn-lint
# cfn-lint -t $INFRASTRUCTURE_FOLDER/01-vpc.yml
# cfn-lint -t $INFRASTRUCTURE_FOLDER/02-ecs.yml

# DEPLOYING VPC (01-vpc.yaml) CLOUDFORMATION RESOURCES
# https://docs.aws.amazon.com/cli/latest/reference/cloudformation/deploy/#examples
echo "[deploy-ecs-cluster] Deploying $STACK_NAME-vpc stack..."
aws cloudformation deploy --stack-name $STACK_NAME-vpc --capabilities CAPABILITY_IAM --parameter-overrides VPCName=$CLUSTER_NAME --template-file $INFRASTRUCTURE_FOLDER/01-vpc.yml
# Waiting until CloudFormation stack 01-vpc.yaml completion, avoiding raise conditions
export VPC_STACK_ARN=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME-vpc" | awk -F'"' '/"StackId"/ {print $4}')
aws cloudformation wait stack-create-complete --stack-name $VPC_STACK_ARN

# CREATING NECESSARY KEY PAIR
echo "[deploy-ecs-cluster] Creating necessary key pair $KEY_PAIR_NAME..."
# https://docs.aws.amazon.com/cli/latest/reference/ec2/create-key-pair.html
aws ec2 create-key-pair --key-name $KEY_PAIR_NAME --output text > $KEY_PAIR_NAME.pem

# DEPLOYING ECS CLUSTER (02-ecs.yml) CLOUDFORMATION RESOURCES
echo "[deploy-ecs-cluster] Deploying $STACK_NAME-ecs stack..."
aws cloudformation deploy --stack-name $STACK_NAME-ecs --capabilities CAPABILITY_IAM --parameter-overrides DesiredCapacity=1 MaxSize=2 InstanceType=t2.micro ECSClusterName=$CLUSTER_NAME --template-file $INFRASTRUCTURE_FOLDER/02-ecs.yml
# Waiting until CloudFormation stack 02-ecs.yml completion, avoiding raise conditions
export ECS_STACK_ARN=$(aws cloudformation describe-stacks --stack-name $STACK_NAME-ecs  | awk -F'"' '/"StackId"/ {print $4}')
aws cloudformation wait stack-create-complete --stack-name $ECS_STACK_ARN
