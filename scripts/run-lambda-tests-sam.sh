#!/bin/bash

# Creating sam hello-world boilerplate
# https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-init.html
cd $SAM_FOLDER/$LAMBDA_FUNCTION_NAME

# Testing regular case
echo "\n\n[run-lambda-test-sam] REGULAR CASE"
sam local invoke --event ../../$TESTING_FOLDER/lambda-ecs-updater.testevent-base.json

# Testing json validations
echo "\n\n[run-lambda-test-sam] MISSING_JSON_FIELD"
sam local invoke --event ../../$TESTING_FOLDER/lambda-ecs-updater.testevent-MISSING_JSON_FIELD.json
echo "\n\n[run-lambda-test-sam] WRONG_JSON_FORMAT"
sam local invoke --event ../../$TESTING_FOLDER/lambda-ecs-updater.testevent-WRONG_JSON_FORMAT.json

# Testing missing AWS resources
echo "\n\n[run-lambda-test-sam] MISSING_ECS_CLUSTER"
sam local invoke --event ../../$TESTING_FOLDER/lambda-ecs-updater.testevent-MISSING_ECS_CLUSTER.json
echo "\n\n[run-lambda-test-sam] MISSING_ECS_SERVICE"
sam local invoke --event ../../$TESTING_FOLDER/lambda-ecs-updater.testevent-MISSING_ECS_SERVICE.json

# Testing aws boto3 params
echo "\n\n[run-lambda-test-sam] WRONG_IMAGE_NAME"
sam local invoke --event ../../$TESTING_FOLDER/lambda-ecs-updater.testevent-WRONG_IMAGE_NAME.json
echo "\n\n[run-lambda-test-sam] MULTIPLE_TAGS"
sam local invoke --event ../../$TESTING_FOLDER/lambda-ecs-updater.testevent-MULTIPLE_TAGS.json
echo "\n\n[run-lambda-test-sam] SAME_INITIAL_VALUES"
sam local invoke --event ../../$TESTING_FOLDER/lambda-ecs-updater.testevent-SAME_INITIAL_VALUES.json
