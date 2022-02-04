#!/bin/bash

# Amazon doc reference
# https://docs.aws.amazon.com/cli/latest/reference/lambda/invoke.html#example

# Testing regular case
echo "\n\n[run-lambda-test-aws] REGULAR CASE"
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME \
    --payload fileb://$TESTING_FOLDER/lambda-ecs-updater.testevent-base.json \
    run-lambda-aws_output.json
cat run-lambda-aws_output.json

# Testing json validations
echo "\n\n[run-lambda-test-aws] MISSING_JSON_FIELD"
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME \
  --payload fileb://$TESTING_FOLDER/lambda-ecs-updater.testevent-MISSING_JSON_FIELD.json \
  run-lambda-aws_output.json
cat run-lambda-aws_output.json
echo "\n\n[run-lambda-test-aws] WRONG_JSON_FORMAT"
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME \
  --payload fileb://$TESTING_FOLDER/lambda-ecs-updater.testevent-WRONG_JSON_FORMAT.json \
  run-lambda-aws_output.json
cat run-lambda-aws_output.json

# Testing missing AWS resources
echo "\n\n[run-lambda-test-aws] MISSING_ECS_CLUSTER"
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME \
  --payload fileb://$TESTING_FOLDER/lambda-ecs-updater.testevent-MISSING_ECS_CLUSTER.json \
  run-lambda-aws_output.json
cat run-lambda-aws_output.json
echo "\n\n[run-lambda-test-aws] MISSING_ECS_SERVICE"
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME \
  --payload fileb://$TESTING_FOLDER/lambda-ecs-updater.testevent-MISSING_ECS_SERVICE.json \
  run-lambda-aws_output.json
cat run-lambda-aws_output.json

# Testing aws boto3 params
echo "\n\n[run-lambda-test-aws] WRONG_IMAGE_NAME"
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME \
  --payload fileb://$TESTING_FOLDER/lambda-ecs-updater.testevent-WRONG_IMAGE_NAME.json \
  run-lambda-aws_output.json
cat run-lambda-aws_output.json
echo "\n\n[run-lambda-test-aws] MULTIPLE_TAGS"
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME \
  --payload fileb://$TESTING_FOLDER/lambda-ecs-updater.testevent-MULTIPLE_TAGS.json \
  run-lambda-aws_output.json
cat run-lambda-aws_output.json
echo "\n\n[run-lambda-test-aws] SAME_INITIAL_VALUES"
aws lambda invoke --function-name $LAMBDA_FUNCTION_NAME \
  --payload fileb://$TESTING_FOLDER/lambda-ecs-updater.testevent-SAME_INITIAL_VALUES.json \
  run-lambda-aws_output.json
cat run-lambda-aws_output.json


# Wrapping up
rm run-lambda-aws_output.json
