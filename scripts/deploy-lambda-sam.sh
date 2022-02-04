#!/bin/bash

# CREATING SAM HELLO-WORLD BOILERPLATE
echo "[deploy-lambda-sam] Creating sam hello-world boilerplate..."
# https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-init.html
mkdir -p $SAM_FOLDER
cd $SAM_FOLDER
sam init --runtime python3.9 --dependency-manager pip --app-template hello-world --name $LAMBDA_FUNCTION_NAME > /dev/null

# COPYING CUSTOM CODE AND JSON TEST EVENT SCHEMA
echo "[deploy-lambda-sam] Copying custom code and json test event schema..."
cp ../$LAMBDA_CODE_FOLDER/lambda-ecs-updater.py $LAMBDA_FUNCTION_NAME/hello_world/app.py
cp ../$LAMBDA_CODE_FOLDER/lambda-ecs-updater.testevent.schema.json $LAMBDA_FUNCTION_NAME/hello_world/

# INSTALLING DEPENDENCIES
echo "[deploy-lambda-sam] Installing dependencies..."
pip3 install --quiet --target $LAMBDA_FUNCTION_NAME/hello_world/ jsonschema > /dev/null 2>&1

# INVOKING LAMBDA API LOCALLY
echo "[deploy-lambda-sam] Invoking lambda API locally..."
cd $LAMBDA_FUNCTION_NAME
sam local start-lambda > /dev/null 2>&1 &
