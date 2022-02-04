#!/bin/bash

cd $INFRASTRUCTURE_FOLDER_TF

# APPLYING TERRAFORM LAMBDA CONFIGURATION
echo "[deploy-ecs-cluster-tf] Applying terraform ecs-updater-lambda configuration..."
terraform apply -input=false -target=module.ecs-updater-lambda -auto-approve > /dev/null

cd ..
