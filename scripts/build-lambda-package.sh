#!/bin/bash

# Amazon doc reference
# https://docs.aws.amazon.com/lambda/latest/dg/python-package.html#python-package-create-package-with-dependency

# CREATING TEMPORAL FOLDER
echo "[build-lambda-package] Creating temporal folder..."
mkdir -p bundle_tmp

# COPYING COMPONENTS
cp $LAMBDA_CODE_FOLDER/lambda-ecs-updater.testevent.schema.json bundle_tmp/
cp $LAMBDA_CODE_FOLDER/lambda-ecs-updater.py bundle_tmp/

# DOWNLOADING DEPENDENCIES
echo "[build-lambda-package] Downloading dependencies..."
cd bundle_tmp
pip3 install --quiet --target ./package jsonschema > /dev/null 2>&1
cd package/

echo "[build-lambda-package] Compressing dependencies and components into a bundle..."
# COMPRESSING DEPENDENCIES AND COMPONENTS INTO A BUNDLE
zip -q -r ../$LAMBDA_FUNCTION_NAME-package.zip .
cd ..
zip -q -g $LAMBDA_FUNCTION_NAME-package.zip lambda-ecs-updater.testevent.schema.json lambda-ecs-updater.py

# COPYING FINAL PACKAGE BUNDLE
echo "[build-lambda-package] Copying final package bundle..."
cp $LAMBDA_FUNCTION_NAME-package.zip ../$LAMBDA_CODE_FOLDER/

# WRAPPING UP
cd ..
rm -rf bundle_tmp
pwd