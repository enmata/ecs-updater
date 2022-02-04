#!/bin/bash

# CREATING TASK DEFINITION IN ECS CLUSTER
echo "[deploy-ecs-service] Creating task definition in ecs cluster..."
# https://docs.aws.amazon.com/cli/latest/reference/ecs/register-task-definition.html#examples
aws ecs register-task-definition \
    --family $TASK_DEFINITION_NAME \
    --container-definitions "[{\"name\":\"$TASK_DEFINITION_NAME\",\"image\":\"busybox\",\"cpu\":10,\"command\":[\"sleep\",\"360\"],\"memory\":10,\"essential\":true}]" > /dev/null

# CREATING SERVICE IN ECS CLUSTER
echo "[deploy-ecs-service] Creating service in ecs cluster..."
# https://docs.aws.amazon.com/cli/latest/reference/ecs/create-service.html#examples
aws ecs create-service \
    --cluster $CLUSTER_NAME \
    --service-name $SERVICE_NAME \
    --task-definition $TASK_DEFINITION_NAME \
    --desired-count 1 \
    --tags key=$TAG_NAME,value=$TAG_VALUE \
    --propagate-tags SERVICE  > /dev/null
# Waiting until service is stable, avoiding raise conditions
# https://docs.aws.amazon.com/cli/latest/reference/ecs/wait/services-stable.html#examples
aws ecs wait services-stable --services $SERVICE_NAME --cluster $CLUSTER_NAME
