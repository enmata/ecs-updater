"""
Lambda function updating ecs service with json payload information
"""
import json
import boto3
from botocore.exceptions import ClientError, ParamValidationError
import jsonschema

# pylint: disable=missing-module-docstring, line-too-long, consider-using-f-string

def lambda_handler(event, context):
    """ Main lambda handler """

    # Parsing and validating input event format
    json_validation(event)

    # Reading previous configuration
    service_details_before = []
    service_details_before = ecs_service_read(ecs_cluster_name=event['ecs_cluster_name'],
                                              ecs_service_name=event['ecs_service_name'])

    # Updating the service
    ecs_service_update_response = ecs_service_update(ecs_cluster_name=event['ecs_cluster_name'],
                           ecs_service_arn=service_details_before[1],
                           task_definition=service_details_before[2],
                           family=service_details_before[3],
                           memory=service_details_before[5],
                           image=event['ecs_image_name'],
                           old_tags=service_details_before[6],
                           new_tags=event['ecs_tag'])

    # Reading after configuration
    service_details_after = []
    service_details_after = ecs_service_read(ecs_cluster_name=event['ecs_cluster_name'],
                                             ecs_service_name=event['ecs_service_name'])

    return {
        	"statusCode": ecs_service_update_response['ResponseMetadata']['HTTPStatusCode'],
        	"body": {
        		"BEFORE": {
        			"clusterArn": service_details_before[0],
        			"serviceArn": service_details_before[1],
        			"taskDefinitionName": service_details_before[2],
        			"taskDefinitionFamily": service_details_before[3],
        			"serviceImage": service_details_before[4],
        			"serviceMemory": service_details_before[5],
        			"tags": service_details_before[6],
                    "updatedOn": service_details_before[7]
        		},
        		"AFTER": {
        			"clusterArn": service_details_after[0],
        			"serviceArn": service_details_after[1],
        			"taskDefinitionName": service_details_after[2],
        			"taskDefinitionFamily": service_details_after[3],
        			"serviceImage": service_details_after[4],
        			"serviceMemory": service_details_after[5],
        			"tags": service_details_after[6],
                    "updatedOn": service_details_after[7]
        		}
        	}
        }


def ecs_service_read(ecs_cluster_name, ecs_service_name) -> []:
    """
    Getting actual ecs service configuration, returning returning clusterArn, serviceArn, task definition name, task definition family, service image, memory, update time and tags.
    """

    # Registering needed boto3 clients
    ecs_client = boto3.client('ecs')

    # Checking ecs service clusterArn, serviceArn and tags
    try:
        services_response = []
        services_response = ecs_client.describe_services(
            cluster=ecs_cluster_name,
            services=[ecs_service_name],
            include=['TAGS']
        )
    # Handling errors
    except ClientError as error:
        if error.response['Error']['Code'] == 'ClusterNotFoundException':
            error_message = "[ERROR][ecs_service_read] ecs_cluster_name {} not found".format(ecs_cluster_name)
            raise Exception(error_message)
        else:
            error_message = "[ERROR][ecs_service_read] reading ecs service unexpected error: {}".format(ecs_service_name)
            raise Exception(error_message)
    except ParamValidationError as error:
        print("[ERROR][ecs_service_read] reading ecs service unexpected error: {}".format(error))
    # If there is no services on response, service with that name is not found
    if not services_response['services']:
        error_message = "[ERROR][ecs_service_read] ecs_service_name {} not found".format(ecs_service_name)
        raise Exception(error_message)

    # Checking image, memory, task name and task family on ecs service taskDefinition
    response_definition = ecs_client.describe_task_definition(
        taskDefinition=services_response['services'][0]['taskDefinition']
    )

    # Handling no tags case
    old_tags = services_response['services'][0]['tags'] if ('tags' in services_response['services'][0]) else []

    # Returning clusterArn, serviceArn, task definition name, task definition family, service image, memory, and tags
    service_details = []
    service_details = [services_response['services'][0]['clusterArn'],
                       services_response['services'][0]['serviceArn'],
                       response_definition['taskDefinition']['containerDefinitions'][0]['name'],
                       response_definition['taskDefinition']['family'],
                       response_definition['taskDefinition']['containerDefinitions'][0]['image'],
                       response_definition['taskDefinition']['containerDefinitions'][0]['memory'],
                       old_tags,
                       str(services_response['services'][0]['deployments'][0]['updatedAt'])]

    return service_details

def ecs_service_update(ecs_cluster_name, ecs_service_arn, task_definition, family, memory, image, old_tags,
                       new_tags) -> []:
    """
    Updating ecs service, with new image on task definition and tags.
    """

    # Registering needed boto3 clients
    ecs_client = boto3.client('ecs')
    tag_client = boto3.client('resourcegroupstaggingapi')

    # Creating new ecs task definition with new image
    try:
        register_task_definition_response = []
        register_task_definition_response = ecs_client.register_task_definition(
            family=family,
            containerDefinitions=[
                {
                    'name': task_definition,
                    'image': image,
                    'memory': memory
                },
            ])
    # Handling errors
    except ClientError as error:
        error_message = "[ERROR][ecs_service_update] new task_definition could not be created {}".format(error.response['Error']['Message'])
        raise Exception(error_message)

    # Updating the ecs service with the new task definition
    try:
        update_service_response = []
        update_service_response = ecs_client.update_service(
                cluster=ecs_cluster_name,
                service=ecs_service_arn,
                taskDefinition=register_task_definition_response['taskDefinition']['taskDefinitionArn']
        )

    # Handling errors
    except ClientError as error:
        print("[ERROR][ecs_service_update] service could not be update with new task_definition {}".format(error.response['Error']['Message']))

    # Updating ecs service tags
    keys_to_delete = []
    for tag in old_tags:
        keys_to_delete.append(tag['key'])

    try:
        if keys_to_delete:
            untag_reponse = tag_client.untag_resources(
                ResourceARNList=[ecs_service_arn],
                TagKeys=keys_to_delete )
            print(untag_reponse)
        tag_response = tag_client.tag_resources(
            ResourceARNList=[ecs_service_arn],
            Tags=new_tags)
        print(tag_response)
    # Handling errors
    except ParamValidationError as error:
        error_message = "[ERROR][ecs_service_update] service tags could not be updated (ParamValidationError) {}".format(new_tags)
        raise Exception(error_message)
    except ClientError as error:
        error_message = "[ERROR][ecs_service_update] service tags could not be updated (ClientError) {}".format(new_tags)
        raise Exception(error_message)
    if (len(untag_reponse['FailedResourcesMap']) or len(tag_response['FailedResourcesMap'])):
        error_message = "[ERROR][ecs_service_update] updating service tag unexpected error: {}".format(new_tags)
        raise Exception(error_message)

    # Returning service update boto3 response
    return update_service_response

def json_validation(eventjson) -> None:
    """
    Parsing and validating input event format.
    """

    # Loading validation schema
    with open("lambda-ecs-updater.testevent.schema.json", "r", encoding='utf8') as file_schema:
        json_schema = json.load(file_schema)

    # Validating input json against json schema
    try:
        validate_out = jsonschema.validate(eventjson, json_schema)
    # Handling errors
    except jsonschema.exceptions.ValidationError as error:
        error_message = "[ERROR][json_validation] wrong input event format: {}".format(error.message)
        raise Exception(error_message)
