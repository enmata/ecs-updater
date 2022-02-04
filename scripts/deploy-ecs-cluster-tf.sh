#!/bin/bash

cd $INFRASTRUCTURE_FOLDER_TF

# INITIALIZING TERRAFORM ENVIRONMENT
terraform init > /dev/null

# VALIDATING TERRAFORM CONFIGURATION SYNTAX
echo "[deploy-ecs-cluster-tf] Validating configuration syntax..."
terraform validate

# APPLYING TERRAFORM VPC AND ECS-CLUSTER CONFIGURATION
echo "[deploy-ecs-cluster-tf] Applying terraform vpc configuration..."
terraform apply -input=false -var="ecs-updater-ecs-cluster_ecs_cluster-name=$CLUSTER_NAME" -var="ecs-updater-ecs-cluster_key_pair-name=$KEY_PAIR_NAME" -var="ecs-updater-ecs-cluster-lambda_function_name=$LAMBDA_FUNCTION_NAME" -target=module.ecs-updater-vpc -auto-approve > /dev/null
echo "[deploy-ecs-cluster-tf] Applying terraform ecs-cluster configuration..."
terraform apply -input=false -var="ecs-updater-vpc_region=$AWS_DEFAULT_REGION" -target=module.ecs-updater-ecs-cluster -auto-approve > /dev/null

cd ..
