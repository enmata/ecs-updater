## ecs-updater

### Table of contents:
 * [Abstract](#abstract)
 * [Main Folder structure](#main-folder-structure)
 * [Tools and libraries](#tools-and-libraries)
 * [Assumptions, requirements and considerations](#assumptions--requirements-and-considerations)
 * [Deployment pipeline and testing with make file](#deployment-pipeline-and-testing-with-make-file)
 * [Package bundle folder structure](#package-bundle-folder-structure)
 * [Testing](#testing)
 * [Error handling](#error-handling)
 * [Technical decisions](#technical-decisions)
 * [Possible future upgrades](#possible-future-upgrades)


### Abstract
This document tries to explain ecs-updater workflow, architecture and its usage.
Solution is based on a python lambda function, updating a specific ecs service with the image and tags specified on the entering event json payload.
- The workflow is managed by a Makefile
- Lambda is using python and json library
- Lambda deploy is managed by CloudFormation template
- Local testing is done in local using SAM framework
- Remote AWS testing is using AWS cli


### Main folder structure
Files and scripts has been distributed as follows:
```
├── Makefile            _# Makefile defining the workflow deploying, testing, and wrapping up the application_
├── README.rd           _# original project requirements_
├── SOLUTION.rd         _# project documentation_
├── infraestructure     _# folder containing CloudFormation templates used during the deploy_
    ├── 01-vpc.yml      _# CloudFormation yaml template defining necessary AWS VPC_
    ├── 02-ecs.yml      _# CloudFormation yaml template defining ECS cluster_
    └── 03-lambda.yml   _# CloudFormation yaml template defining lambda function, roles and permissions_
├── infraestructure-terraform           _# folder containing terraform custom modules used during the deploy_
    ├── modules/ecs-updater-ecs-cluster _# terraform custom configuration module setting up vpc_
    ├── modules/ecs-updater-lambda      _# terraform custom configuration module setting up vpc_
    ├── modules/ecs-updater-vpc         _# terraform custom configuration module setting up vpc_
    ├── main.tf                         _# main configuration file_
    └── provider.tf                     _# necessary configuration file using official aws provider_
├── lambda_code         _# Folder containing CloudFormation yaml templates used during the deploy_
    ├── lambda-ecs-updater.py                    _# main python code of ecs-updater_
    └── lambda-ecs-updater.testevent.schema.json _# json schema parsing event entries_
├── scripts     _# Folder containing different scripts managing each step_
    ├── build-lambda-package.sh _# script downloading the necessary dependencies to run lambda function (jsonschema), and compresing it inside a zip bundle on "lambda_code" folder_
    ├── deploy-ecs-cluster.sh   _# script deploying the CloudFormation stack on aws defined on "infraestructure" folder_
    ├── deploy-ecs-cluster-tf.sh _# script deploying the terraform vpc and ecs-cluster module_
    ├── deploy-ecs-service.sh   _# script creating the necessary ecs task definition and services for testing by aws cli command line_
    ├── deploy-lambda-aws.sh    _# script creating the lambda function on aws by deploying the CloudFormation lambda stack defined on "infraestructure" folder and uploading the code by aws client_
    ├── deploy-lambda-aws-tf.sh _# script deploying the terraform lambda module_
    ├── deploy-lambda-sam.sh    _# script initializing a temporary folder to run lambda test using AWS Serverless Application Model_
    ├── run-lambda-tests-aws.sh _# script running sequentially lambda test on aws, defined by json files on "testing" folder, by using aws cli_
    ├── run-lambda-tests-inittest.sh _# script running sequentially lambda test on aws, defined by json files on "testing" folder using inittest python3 class_
    ├── run-lambda-tests-sam.sh _# script running sequentially locally lambda tests defined by json files on "testing" folder, using sam framework on testing temporary folder_
    └── wrap-up.sh              _# script deleting the generated resources during the Makefile workflow_
└── testing         _# Folder containing inittest python3 class and json entry events testing function behaviour_
    ├── test_ecs-updater.py                 _# inittest python3 class running sequentially entry events testing function behaviour_
    ├── test_ecs-updater_requirements.txt   _# pip dependencies for inittest_
    └── *json                               _# json files containing entry events testing function behaviour_
```


### Tools and libraries
The following tools has been used:
- Lambda implementation
    - python [3.9]        _# running main function code_
    - python pip modules (and it's dependencies)
        - boto3/botocore _# AWS SDK interacting with AWS resources_
        - json          _# managing boto3 data fields_
        - jsonschema    _# parsing and validating testevent json input_
- Testing
    - AWS Serverless Application Model (SAM) framework _# running lambda locally emulating AWS cloud behaviour_
    - Docker [20.10.8]      _# AWS SAM framework requirement to run lambda locally_
    - python [3.9]        _# running main function code_
    - python pip modules (and it's dependencies)
        - boto3/botocore _# AWS SDK interacting with AWS resources_
        - json          _# managing boto3 data fields_
        - pytest        _# managing unit test cases_
        - unittest      _# implementing unit test cases response checks_
        - virtualenv    _# creating temporal python virtual environment_
- Deploy
    - CloudFormation      _# implementing resources stacks defined in "infrastructure" folder_
    - aws cli             _# creating running lambda_
    - terraform [1.1.3]   _# deploying vpc, ecs clister and lambda function using a custom terraform modules on "infrastructure-terraform" module_
    - terraform modules and providers (and it's dependencies)
      - aws               _# provider plugin managing aws ecs and lambda deploys_
      - aws(vpc)          _# module managing aws vpc deploys_
    - VPC and ECS Cluster terraform yaml templates examples took from awslabs public repository:
      VPC         [01-ecs.yaml](https://github.com/awslabs/aws-cloudformation-templates/blob/master/aws/services/ECS/EC2LaunchType/clusters/public-vpc.yml)
      ECS Cluster [02-ecs.yaml](https://github.com/awslabs/aws-cloudformation-templates/blob/master/aws/services/VPC/VPC_With_Managed_NAT_And_Private_Subnet.yaml)


Please, find the tool used for each Makefile rule on the following table

|                          | all-local                | all-aws                  | all-aws-tf    |
|--------------------------|--------------------------|--------------------------|---------------|
| vpc                      | -                        | CloudFormation           | Terraform     |
| ecs-cluster              | CloudFormation           | CloudFormation           | Terraform     |
| lambda function          | CloudFormation + aws cli | CloudFormation + aws cli | Terraform     |
| dummy ecs service        | aws cli                  | aws cli                  | aws cli       |
| run-lambda-test-sam      | sam                      | -                        | -             |
| run-lambda-test-aws      | -                        | aws cli                  | aws cli       |
| run-lambda-test-unittest | -                        | python pytest            | python pytest |

### Assumptions, requirements and considerations
Running the Makefile assumes:
- AWS cli installed, with credentials with access and rights to create CloudFormation stacks and edit ECS resources
- AWS Serverless Application Model (SAM) framework installed
- docker daemon is running (for local AWS SAM testing)
- python3 virtualenv and pip3 installed and PATH accessible
- terraform binary installed (for terraform deploys)
- you have access to internet (pip3 and terraform repositories) for downloading public libraries
- other tools like make, zip and awk installed and PATH accessible


### Deployment pipeline and testing with make file
The following rules has been defined on the Makefile
- **all-local** _(< 15m)_
    running sequentially all the workflow locally using AWS Serverless Application Model
- **all-aws** _(< 16m)_
    running sequentially all the workflow for AWS using CloudFormation
- **all-aws-tf** _(< 15m)_
    	# runs sequentially all the workflow for AWS using terraform custom modules
- **build-lambda-package** _(< 15s)_
    creating needed package bundle with lambda code and pip dependencies (json schema)
- **deploy-ecs-cluster** _(< 8m)_
    creating needed vpc and ecs cluster using CloudFormation stacks
- **deploy-ecs-cluster-tf** _(< 5m)_
    creating needed vpc and ecs cluster using terraform custom modules
- **deploy-ecs-service** _(< 30s)_
    creating dummy ecs services in aws
- **deploy-lambda-sam** _(< 15s)_
	creating lambda function locally using AWS Serverless Application Model
- **deploy-lambda-aws** _(< 2m)_
    creating lambda function in aws using CloudFormation
- **deploy-lambda-aws-tf** _(< 2m)_
    creating lambda function in aws using terraform custom modules
- **run-lambda-test-sam** _(< 1m)_
    running lambda function locally using AWS Serverless Application Model
- **run-lambda-test-aws** _(< 30s)_
    running lambda function on AWS using aws cli
- **run-lambda-test-inittest** _(< 30s)_
    running lambda function using python3 inittest for unit test
- **clean** _(< 5m)_
    wrapping up created resources






### Package bundle folder structure
To upload all the lambda code and its dependencies to AWS, a zip package is generated on "build-lambda-package" step. Files and scripts inside that file has been distributed as follows:
```
├── lambda-ecs-updater.testevent.schema.json  _# definitions of json schema to parse all entry_
├── lambda-ecs-updater.py                     _# main function python code, referenced on lambda CloudFormation stack_
└── * pip3 requisites (all other files)   _# pip3 jsonschema and its dependencies, necessary for json parsing_
```


### Testing
The following test cases has been covered:
#### eventtest defined in json files

- **Base case**: normal behaviour, with all correct fields, editing properly the needed ecs service creating a new task service definition
    - json testevent: _lambda-ecs-updater.testevent-base.json_
    - exceptions: none
- **Missing ecs cluster**: entering a valid json with all needed fields, but pointing to a non-existent es cluster (wrong name)
    - json testevent: _lambda-ecs-updater.testevent-MISSING_ECS_CLUSTER.json_
    - exceptions: `[ERROR][ecs_service_read] ecs_cluster_name {} not found`
- **Missing ecs service**: entering a valid json with all needed fields, but pointing to a non-existent ecs service (wrong name)
    - json testevent: _lambda-ecs-updater.testevent-MISSING_ECS_SERVICE.json_
    - exceptions:  `[ERROR][ecs_service_read] reading ecs service unexpected error: {}`
                    `[ERROR][ecs_service_read] ecs_service_name {} not found`
- **Multiple tags**: testevent with all correct fields, adding 2 tags
    - json testevent: _lambda-ecs-updater.testevent-MULTIPLE_TAGS.json_
    - exceptions: none
- **Wrong image name**: json containing an image name not accepted for AWS requirements.
    - json testevent: lambda-ecs-updater.testevent-WRONG_IMAGE_NAME.json
    - exceptions:  `[ERROR][ecs_service_update] new task_definition could not be created {}`
- **Same initial values**: normal behaviour, with all correct fields, checking behaviour after inserting same values as creation initial values
        - json testevent: _lambda-ecs-updater.testevent-SAME_INITIAL_VALUES.json_
        - exceptions: none
- **Missing json field**: json with not all the required fields ("ecs_cluster_name",	"ecs_service_name", "ecs_image_name" and "ecs_tag"). Checked against json schema defined in _lambda-ecs-updater.testevent.schema.json_ file using python jsonschema validation.
    - json testevent: _lambda-ecs-updater.testevent-MISSING_JSON_FIELD.json_
    - exceptions:  `[ERROR][json_validation] wrong input event format: {}`
                    `[ERROR][json_validation] Needed: {}`
- **Wrong json format**: same as above, json with the necessary fields but not vales are just a string
    - json testevent: lambda-ecs-updater.testevent-WRONG_JSON_FORMAT.json
    - exceptions:  `[ERROR][json_validation] wrong input event format: {}`
                    `[ERROR][json_validation] Needed: {}`

**Additional notes**
- Json files events are defined assuming default variables of Makefiles. Changing that variables on Makefiles needs changing in json files values accordingly.
- Exception messages are shown using sam framework _("make run-lambda-test-sam")_, but not in aws testing _("make run-lambda-test-aws" and "run-lambda-test-unittest")_.

The following exceptions could be forced to raise by revoking permissions on the running account:
  - `[ERROR][ecs_service_update]` service could not be update with new task_definition {}
  - `[ERROR][ecs_service_update]` service tags could not be updated (ParamValidationError) {}
  - `[ERROR][ecs_service_update]` service tags could not be updated (ClientError) {}
  - `[ERROR][ecs_service_update]` updating service tag unexpected error: {}

#### Unit testing with Python3 inittest

- 1.x Testing Regular Case
  - `[FAILED CHECK 1.1.1]` ecs-updater RegularCase - Lambda Execution ResponseCode
  - `[FAILED CHECK 1.1.2]` ecs-updater RegularCase - Lambda Payload before Image
  - `[FAILED CHECK 1.1.3]` ecs-updater RegularCase - Lambda Payload before tags
  - `[FAILED CHECK 1.1.4]` ecs-updater RegularCase - Lambda Payload after Image
  - `[FAILED CHECK 1.1.5]` ecs-updater RegularCase - Lambda Payload after tags
- 2.x Testing JSON
  - `[FAILED CHECK 2.1.1]` ecs-updater json - Lambda Execution json MISSING_JSON_FIELD ResponseCode
  - `[FAILED CHECK 2.1.2]` ecs-updater json - Lambda Payload json MISSING_JSON_FIELD expected errorType
  - `[FAILED CHECK 2.1.3]` ecs-updater json - Lambda Payload json MISSING_JSON_FIELD expected error_message
  - `[FAILED CHECK 2.2.1]` ecs-updater json - Lambda Execution json JSON_FORMAT ResponseCode
  - `[FAILED CHECK 2.2.2]` ecs-updater json - Lambda Payload json JSON_FORMAT expected errorType
  - `[FAILED CHECK 2.2.3]` ecs-updater json - Lambda Payload json JSON_FORMAT expected error_message
- 3.x Testing missing AWS resources
  - `[FAILED CHECK 3.1.1]` ecs-updater json - Lambda Execution json MISSING_JSON_FIELD ResponseCode
  - `[FAILED CHECK 3.1.2]` ecs-updater json - Lambda Payload json MISSING_JSON_FIELD expected errorType
  - `[FAILED CHECK 3.1.3]` ecs-updater json - Lambda Payload json MISSING_JSON_FIELD expected error_message
  - `[FAILED CHECK 3.2.1]` ecs-updater json - Lambda Execution json JSON_FORMAT ResponseCode
  - `[FAILED CHECK 3.2.2]` ecs-updater json - Lambda Payload json JSON_FORMAT expected errorType
  - `[FAILED CHECK 3.2.3]` ecs-updater json - Lambda Payload json JSON_FORMAT expected error_message
- 4.x Testing aws boto3 params
  - `[FAILED CHECK 4.1.1]` ecs-updater aws boto3 params - Lambda Execution WRONG_IMAGE_NAME ResponseCode
  - `[FAILED CHECK 4.1.2]` ecs-updater aws boto3 params - Lambda Payload WRONG_IMAGE_NAME expected errorType
  - `[FAILED CHECK 4.1.3]` ecs-updater aws boto3 params - Lambda Payload WRONG_IMAGE_NAME expected error_message
  - `[FAILED CHECK 4.2.1]` ecs-updater aws boto3 params - Lambda Execution SAME_INITIAL_VALUES ResponseCode
  - `[FAILED CHECK 4.2.2]` ecs-updater aws boto3 params - Lambda Payload SAME_INITIAL_VALUES before Image
  - `[FAILED CHECK 4.2.3]` ecs-updater aws boto3 params - Lambda Payload SAME_INITIAL_VALUES before tags
  - `[FAILED CHECK 4.2.4]` ecs-updater aws boto3 params - Lambda Payload SAME_INITIAL_VALUES after Image
  - `[FAILED CHECK 4.2.5]` ecs-updater aws boto3 params - Lambda Payload SAME_INITIAL_VALUES after tags
  - `[FAILED CHECK 4.3.1]` ecs-updater aws boto3 params - Lambda Execution MULTIPLE_TAGS ResponseCode
  - `[FAILED CHECK 4.3.2]` ecs-updater aws boto3 params - Lambda Execution MULTIPLE_TAGS Payload after Image
  - `[FAILED CHECK 4.3.3]` ecs-updater aws boto3 params - Lambda Execution MULTIPLE_TAGS after tag 1
  - `[FAILED CHECK 4.3.4]` ecs-updater aws boto3 params - Lambda Execution MULTIPLE_TAGS after tag 2

### Error handling
The following exception error messages has been defined on the function:
  - `[ERROR][ecs_service_read]` ecs_cluster_name {} not found
  - `[ERROR][ecs_service_read]` reading ecs service unexpected error: {}
  - `[ERROR][ecs_service_read]` ecs_service_name {} not found
  - `[ERROR][ecs_service_update]` new task_definition could not be created {}
  - `[ERROR][ecs_service_update]` service could not be update with new task_definition {}
  - `[ERROR][ecs_service_update]` service tags could not be updated {}
  - `[ERROR][ecs_service_update]` updating service tag unexpected error: {}
  - `[ERROR][json_validation]` wrong input event format: {}
  - `[ERROR][json_validation]` Needed: {}


### Technical decisions
The following decisions has been considered done during the implementation:
- workflow/deploy
  - lambda creation has been separated on 2 steps. On a first step Lambda function is declared in CloudFormation stack with a sample code with all the necessary roles and permissions. On a second step the lambda function is updated using aws cli uploading the local zip package. These avoids upload lambda code to a s3 bucket.
  - default parameters has been overridden on CloudFormation stack (IE: Environment ($CLUSTER_NAME) and  KeyPairName), making sure references are consistent in all resources.
  - default AWS region has been set to ireland (AWS_DEFAULT_REGION=eu-west-1)
  - variables has been grouped on initial part of the Makefile. These creates a unique point where to modify that parameters, making sure references are consistent in all scripts.
  - waiting CloudFormation stack creation (_aws cloudformation wait stack-create-complete_) and deletion (_aws cloudformation wait stack-delete-complete_) has been added to force command completion, avoiding raise conditions.
  - makefile executes external files. All necessary commands has been grouped to a specific scripts. This has been done for Makefile reading clarity.
- terraform workflow
  - terraform deploy has been splitted on 3 modules for better understanding
  - terraform modules has been pinned to a specific versions avoiding breaking changes on newer versions
  - tag "ecs-updater-terraform" are being added from al modules for an easy identification
- lambda implementation
  - only one lambda execution at a time is allowed using "ReservedConcurrentExecutions" parameter on CloudFormation stack yaml definition. These has been set avoiding raise conditions.
  - a default timeout has been defined using "Timeout: '30' parameter on CloudFormation stack yaml definition as a best practice.
  - log generation rights has been restriction. In case its a future requirements can be added.
- python lambda function code
  - exceptions and error handling has been implemented in the different lambda functions, avoiding to expose all information on error traces.
  - python linting has been check using python pylint module
  - even most errors and exceptions are managed before, final lambda response code is based on boto3 answer on update_service http status response, avoiding response hardcoding
  - last edit timestamp has been added on json body checking the time interval
- python unit test using pytest and inittest
  - python class is running on an isolated virtual environment created by virtualenv, and it's deleted after that
  - non default verbosity and "short test summary info" table has been added using "-v -rA" command line switches
  - on first regular case service image is changed on the background (from busybox to nginx), and the next cases has been adapted for that
  - As mentioned before, exception messages are shown using sam framework _(`make run-lambda-test-sam`)_, but not in aws testing _(`make run-lambda-test-aws` and `run-lambda-test-unittest`)_. Assert messages has been adapted for the actual status.
- security
  - a key pair is needed during initial ecs CloudFormation stack deploy. This has been automated using aws cli, storing the certificate locally
  - only necessary permissions to edit ecs services and service definitions has been allowed to lambda function on a custom role to security.
  - json schema validation for all entering testevent, reducing surface attach and avoiding wrong parameters


### Possible future upgrades
- Error external alerting based on error executions integrated with [CloudWatch](https://aws.amazon.com/blogs/mt/get-notified-specific-lambda-function-error-patterns-using-cloudwatch/)
- Implement inittest make script against sam local [endpoint-url](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/sam-cli-command-reference-sam-local-start-lambda.html)
- Implement inittest make script against a local docker image by using AWS emulation [localstack](https://github.com/localstack/localstack)
- Implement additional fields on json testevent, modifying additional [service parameters](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ecs.html)
- Create an additional lambda function, with more restricted permissions, only for reading actual ecs service parameters
- Event based lambda trigger on an image update or a [commit change](https://docs.aws.amazon.com/lambda/latest/dg/invocation-eventsourcemapping.html)
- Edit ecs services inside an organization, on a different AWS account, using functionality ["assumeRole"](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-api.html)
- parametrize terraform modules, avoiding hardcoded values using [output configuration](https://www.terraform.io/language/values/outputs) should be used to pass values between modules.
- Image name check on [image repository api](https://docs.docker.com/registry/spec/api/#listing-image-tags)
- Store changes history with [AWS config](https://aws.amazon.com/about-aws/whats-new/2021/02/aws-config-supports-amazon-container-services/)
- API Gateway possible implementation, making easy lambda integration and REST reachable
- In case API Gateway is implemented, migrate json schema validation to [native JSON Schema Validation](https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-method-request-validation.html)
- In case API Gateways is implemented, API authentication. IE: [token based](https://docs.aws.amazon.com/apigateway/latest/developerguide/apigateway-use-lambda-authorizer.html)
