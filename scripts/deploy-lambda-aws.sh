#!/bin/bash

# VALIDATING CLOUDFORMATION YAML SYNTAX
echo "[deploy-lambda-aws] Validating CloudFormation yaml syntax..."
# https://docs.aws.amazon.com/cli/latest/reference/cloudformation/validate-template.html#examples
aws cloudformation validate-template --template-body file://$INFRASTRUCTURE_FOLDER/03-lambda.yml > /dev/null
# Disabled due not present by default in aws cli
# https://github.com/aws-cloudformation/cfn-lint
# cfn-lint -t $INFRASTRUCTURE_FOLDER/03-lambda.yml

# DEPLOYING VPC (03-lambda.yml) CLOUDFORMATION RESOURCES
# https://docs.aws.amazon.com/cli/latest/reference/cloudformation/deploy/#examples
echo "[deploy-lambda-aws] Deploying $STACK_NAME-lambda stack..."
aws cloudformation deploy --stack-name $STACK_NAME-lambda --capabilities CAPABILITY_IAM --parameter-overrides LambdaFunctionName=$LAMBDA_FUNCTION_NAME --template-file $INFRASTRUCTURE_FOLDER/03-lambda.yml  > /dev/null
# Waiting until CloudFormation stack 01-vpc.yaml completion, avoiding raise conditions
export LAMBDA_STACK_ARN=$(aws cloudformation describe-stacks --stack-name "$STACK_NAME-lambda" | awk -F'"' '/"StackId"/ {print $4}')
aws cloudformation wait stack-create-complete --stack-name $LAMBDA_STACK_ARN

# UPLOADING LAMBDA CODE TO AWS
echo "[deploy-lambda-aws] Uploading lambda code to aws..."
# https://docs.aws.amazon.com/cli/latest/reference/lambda/update-function-code.html#examples
aws lambda update-function-code --function-name $LAMBDA_FUNCTION_NAME --zip-file fileb://$LAMBDA_CODE_FOLDER/$LAMBDA_FUNCTION_NAME-package.zip > /dev/null
