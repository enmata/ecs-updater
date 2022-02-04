# Setting variables
# Folder fixed variables (could not be changed)
export LAMBDA_CODE_FOLDER=lambda_code
export INFRASTRUCTURE_FOLDER=infra-cf
export INFRASTRUCTURE_FOLDER_TF=infra-tf
export TESTING_FOLDER=testing
# Rest variables (the following can be changed)
export TASK_DEFINITION_NAME=ecs-dummy-task-definition
export SERVICE_NAME=ecs-dummy-service
export CLUSTER_NAME=ECSCluster
export TAG_NAME=old-custom-tag-name
export TAG_VALUE=old-custom-tag-value
export STACK_NAME=testing-stack
export KEY_PAIR_NAME=dummy-key-pair
export LAMBDA_FUNCTION_NAME=ecs-updater
export SAM_FOLDER=testing-lambda-sam
export AWS_DEFAULT_REGION=eu-west-1

all-local: deploy-ecs-cluster-cf deploy-ecs-service deploy-lambda-sam run-lambda-test-sam clean
	# runs sequentially all the workflow locally using AWS Serverless Application Model

all-aws-cf: build-lambda-package deploy-ecs-cluster-cf deploy-ecs-service deploy-lambda-aws run-lambda-test-unittest run-lambda-test-aws clean
	# runs sequentially all the workflow for AWS using CloudFormation

all-aws-tf: build-lambda-package deploy-ecs-cluster-tf deploy-ecs-service deploy-lambda-aws-tf run-lambda-test-unittest run-lambda-test-aws clean
	# runs sequentially all the workflow for AWS using terraform

build-lambda-package:
	# creating needed package bundle with lambda code and pip dependencies (json schema)
	sh scripts/build-lambda-package.sh

deploy-ecs-cluster-cf:
	# creating needed vpc and ecs cluster using cloudformation stacks
	sh scripts/deploy-ecs-cluster-cf.sh

deploy-ecs-cluster-tf:
	# creating needed vpc and ecs cluster in AWS using terraform
	sh scripts/deploy-ecs-cluster-tf.sh

deploy-ecs-service:
	# creating dummy ecs services in aws
	sh scripts/deploy-ecs-service-cf.sh

deploy-lambda-sam:
	# creating lambda function locally using AWS Serverless Application Model
	sh scripts/deploy-lambda-sam.sh

deploy-lambda-aws:
	# creating lambda function in aws
	sh scripts/deploy-lambda-aws.sh

deploy-lambda-aws-tf:
	# creating lambda function in AWS using terraform
	sh scripts/deploy-lambda-aws-tf.sh

run-lambda-test-sam:
	# running lambda function locally using AWS Serverless Application Model
	sh scripts/run-lambda-tests-sam.sh

run-lambda-test-aws:
	# running lambda function on AWS using aws cli
	sh scripts/run-lambda-tests-aws.sh

run-lambda-test-unittest:
	# running lambda function on AWS using python3 inittest
	sh scripts/run-lambda-tests-inittest.sh

clean:
	# wrapping up created resources
	sh scripts/wrap-up.sh
