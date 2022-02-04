#!/bin/bash

# Deleting services and task definition
echo "[clean] Deleting services and task definition..."
# https://docs.aws.amazon.com/cli/latest/reference/ecs/delete-service.html#examples
aws ecs delete-service --cluster $CLUSTER_NAME --service $SERVICE_NAME --force > /dev/null 2>&1
# https://docs.aws.amazon.com/cli/latest/reference/ecs/deregister-task-definition.html#examples
for version in $(seq 1 30)
do
  aws ecs deregister-task-definition --task-definition $TASK_DEFINITION_NAME:$version > /dev/null 2>&1
done

# https://docs.aws.amazon.com/cli/latest/reference/cloudformation/delete-stack.html#examples
# https://docs.aws.amazon.com/cli/latest/reference/cloudformation/wait/stack-delete-complete.html#examples
# Deleting from last to first stack
echo "[clean] Deleting $STACK_NAME-lambda CloudFormation stack..."
aws cloudformation delete-stack --stack-name $STACK_NAME-lambda
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME-lambda
echo "[clean] Deleting $STACK_NAME-ecs CloudFormation stack..."
aws cloudformation delete-stack --stack-name $STACK_NAME-ecs
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME-ecs
echo "[clean] Deleting $STACK_NAME-vpc CloudFormation stack..."
aws cloudformation delete-stack --stack-name $STACK_NAME-vpc
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME-vpc

# Deleting terraform resources
cd $INFRASTRUCTURE_FOLDER_TF
echo "[clean] Deleting terraform resources..."
terraform destroy -auto-approve > /dev/null 2>&1
rm -rf .terraform* terraform.tfstate*
cd ..

# https://docs.aws.amazon.com/cli/latest/reference/ec2/delete-key-pair.html
echo "[clean] Deleting temporal files..."
aws ec2 delete-key-pair --key-name $KEY_PAIR_NAME > /dev/null 2>&1
rm -rf $KEY_PAIR_NAME.pem
rm -rf $SAM_FOLDER
rm -rf $LAMBDA_CODE_FOLDER/$LAMBDA_FUNCTION_NAME-package.zip
