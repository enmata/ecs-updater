# !/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Class for testing ecs-api updater lambda function
"""
# pylint: disable=line-too-long, invalid-name, too-many-statements, missing-function-docstring

import unittest
import json
import os
import boto3

class TestECSUpdater(unittest.TestCase):
    """
    Tests all cases we have for ecs-api updater lambda function
    """

    # defining vars
    function_name = os.environ['LAMBDA_FUNCTION_NAME']

    # 1.x Testing Regular Case
    def test1_ecsUpdater_RegularCase(self):

        # Loading client
        lambda_client = boto3.client('lambda')

        # Loading testevent
        with open("lambda-ecs-updater.testevent-base.json", "r", encoding='utf8') as testevent_file:
            testevent_text = testevent_file.read()

        # Running lambda function in aws
        lambda_response = lambda_client.invoke(
            FunctionName=TestECSUpdater.function_name,
            InvocationType='RequestResponse',
            Payload=testevent_text,
        )

        # Formating results
        lambda_response_payload = json.loads(lambda_response['Payload'].read())
        expected_BEFORE_image = "busybox"
        expected_BEFORE_tags = [{'key': 'old-custom-tag-name', 'value': 'old-custom-tag-value'}]
        expected_AFTER_image = "nginx"
        expected_AFTER_tags = [{'key': 'updated-tag-name', 'value': 'updated-tag-value'}]

        # Checking response
        self.assertEqual(lambda_response['ResponseMetadata']['HTTPStatusCode'],200,msg="[FAILED CHECK 1.1.1] ecs-updater RegularCase - Lambda Execution ResponseCode")
        self.assertEqual(lambda_response_payload['body']['BEFORE']['serviceImage'],expected_BEFORE_image,msg="[FAILED CHECK 1.1.2] ecs-updater RegularCase - Lambda Payload before Image")
        self.assertEqual(lambda_response_payload['body']['BEFORE']['tags'],expected_BEFORE_tags,msg="[FAILED CHECK 1.1.3] ecs-updater RegularCase - Lambda Payload before tags")
        self.assertEqual(lambda_response_payload['body']['AFTER']['serviceImage'],expected_AFTER_image,msg="[FAILED CHECK 1.1.4] ecs-updater RegularCase - Lambda Payload after Image")
        self.assertEqual(lambda_response_payload['body']['AFTER']['tags'],expected_AFTER_tags,msg="[FAILED CHECK 1.1.5] ecs-updater RegularCase - Lambda Payload after tags")

    # 2.x Testing JSON
    def test2_ecsUpdater_json(self):

        lambda_client = boto3.client('lambda')

        # 2.1 Testing json MISSING_JSON_FIELD
        with self.subTest(msg="2.1 Testing json MISSING_JSON_FIELD"):

            # Loading testevent
            with open("lambda-ecs-updater.testevent-MISSING_JSON_FIELD.json", "r", encoding='utf8') as testevent_file:
                testevent_text = testevent_file.read()

            # Running lambda function in aws
            lambda_response = lambda_client.invoke(
                FunctionName=TestECSUpdater.function_name,
                InvocationType='RequestResponse',
                Payload=testevent_text,
            )

            # Formating results
            lambda_response_payload = json.loads(lambda_response['Payload'].read())
            expected_error_message = "[ERROR][json_validation] wrong input event format: 'ecs_image_name' is a required property"
            expected_errorType = "Exception"

            # Checking response
            self.assertEqual(lambda_response['ResponseMetadata']['HTTPStatusCode'],200,msg="[FAILED CHECK 2.1.1] ecs-updater json - Lambda Execution json MISSING_JSON_FIELD ResponseCode")
            self.assertEqual(lambda_response_payload['errorType'],expected_errorType,msg="[FAILED CHECK 2.1.2] ecs-updater json - Lambda Payload json MISSING_JSON_FIELD expected errorType")
            self.assertEqual(lambda_response_payload['errorMessage'],expected_error_message,msg="[FAILED CHECK 2.1.3] ecs-updater json - Lambda Payload json MISSING_JSON_FIELD expected error_message")

        # 2.2 Testing json JSON_FORMAT
        with self.subTest(msg="2.2 Testing json JSON_FORMAT"):

            # Loading testevent
            with open("lambda-ecs-updater.testevent-WRONG_JSON_FORMAT.json", "r", encoding='utf8') as testevent_file:
                testevent_text = testevent_file.read()

            # Running lambda function in aws
            lambda_response = lambda_client.invoke(
                FunctionName=TestECSUpdater.function_name,
                InvocationType='RequestResponse',
                Payload=testevent_text,
            )

            # Formating results
            lambda_response_payload = json.loads(lambda_response['Payload'].read())
            expected_error_message = "[ERROR][json_validation] wrong input event format: {'title': 'this is not', 'type': 'just a string'} is not of type 'string'"
            expected_errorType = "Exception"

            # Checking response
            self.assertEqual(lambda_response['ResponseMetadata']['HTTPStatusCode'],200,msg="[FAILED CHECK 2.2.1] ecs-updater json - Lambda Execution json JSON_FORMAT ResponseCode")
            self.assertEqual(lambda_response_payload['errorType'],expected_errorType,msg="[FAILED CHECK 2.2.2] ecs-updater json - Lambda Payload json JSON_FORMAT expected errorType")
            self.assertEqual(lambda_response_payload['errorMessage'],expected_error_message,msg="[FAILED CHECK 2.2.3] ecs-updater json - Lambda Payload json JSON_FORMAT expected error_message")

    # 3.x Testing missing AWS resources
    def test3_ecsUpdater_missingAWSResources(self):

        lambda_client = boto3.client('lambda')

        # 3.1 Testing missing AWS resources MISSING_ECS_CLUSTER
        with self.subTest(msg="3.1 Testing missing AWS resources MISSING_ECS_CLUSTER"):

            # Loading testevent
            with open("lambda-ecs-updater.testevent-MISSING_ECS_CLUSTER.json", "r", encoding='utf8') as testevent_file:
                testevent_text = testevent_file.read()

            # Running lambda function in aws
            lambda_response = lambda_client.invoke(
                FunctionName=TestECSUpdater.function_name,
                InvocationType='RequestResponse',
                Payload=testevent_text,
            )

            # Formating results
            lambda_response_payload = json.loads(lambda_response['Payload'].read())
            expected_error_message = "[ERROR][ecs_service_read] ecs_cluster_name ProductionFAKE not found"
            expected_errorType = "Exception"

            # Checking response
            self.assertEqual(lambda_response['ResponseMetadata']['HTTPStatusCode'],200,msg="[FAILED CHECK 3.1.1] ecs-updater json - Lambda Execution json MISSING_JSON_FIELD ResponseCode")
            self.assertEqual(lambda_response_payload['errorType'],expected_errorType,msg="[FAILED CHECK 3.1.2] ecs-updater json - Lambda Payload json MISSING_JSON_FIELD expected errorType")
            self.assertEqual(lambda_response_payload['errorMessage'],expected_error_message,msg="[FAILED CHECK 3.1.3] ecs-updater json - Lambda Payload json MISSING_JSON_FIELD expected error_message")


        # 3.2 Testing missing AWS resources MISSING_ECS_SERVICE
        with self.subTest(msg="3.2 Testing missing AWS resources MISSING_ECS_SERVICE"):

            # Loading testevent
            with open("lambda-ecs-updater.testevent-MISSING_ECS_SERVICE.json", "r", encoding='utf8') as testevent_file:
                testevent_text = testevent_file.read()

            # Running lambda function in aws
            lambda_response = lambda_client.invoke(
                FunctionName=TestECSUpdater.function_name,
                InvocationType='RequestResponse',
                Payload=testevent_text,
            )

            # Formating results
            lambda_response_payload = json.loads(lambda_response['Payload'].read())
            expected_error_message = "[ERROR][ecs_service_read] ecs_service_name ecs-dummy-serviceFAKE not found"
            expected_errorType = "Exception"

            # Checking response
            self.assertEqual(lambda_response['ResponseMetadata']['HTTPStatusCode'],200,msg="[FAILED CHECK 3.2.1] ecs-updater json - Lambda Execution json JSON_FORMAT ResponseCode")
            self.assertEqual(lambda_response_payload['errorType'],expected_errorType,msg="[FAILED CHECK 3.2.2] ecs-updater json - Lambda Payload json JSON_FORMAT expected errorType")
            self.assertEqual(lambda_response_payload['errorMessage'],expected_error_message,msg="[FAILED CHECK 3.2.3] ecs-updater json - Lambda Payload json JSON_FORMAT expected error_message")

    # 4.x Testing aws boto3 params
    def test4_ecsUpdater_AWSboto3params(self):

        lambda_client = boto3.client('lambda')

        # 4.1 Testing aws boto3 params WRONG_IMAGE_NAME
        with self.subTest(msg="4.1 Testing aws boto3 params WRONG_IMAGE_NAME"):

            # Loading testevent
            with open("lambda-ecs-updater.testevent-WRONG_IMAGE_NAME.json", "r", encoding='utf8') as testevent_file:
                testevent_text = testevent_file.read()

            # Running lambda function in aws
            lambda_response = lambda_client.invoke(
                FunctionName=TestECSUpdater.function_name,
                InvocationType='RequestResponse',
                Payload=testevent_text,
            )

            # Formating results
            lambda_response_payload = json.loads(lambda_response['Payload'].read())
            expected_error_message = "[ERROR][ecs_service_update] new task_definition could not be created Container.image repository should not be null or empty."
            expected_errorType = "Exception"

            # Checking response
            self.assertEqual(lambda_response['ResponseMetadata']['HTTPStatusCode'],200,msg="[FAILED CHECK 4.1.1] ecs-updater aws boto3 params - Lambda Execution WRONG_IMAGE_NAME ResponseCode")
            self.assertEqual(lambda_response_payload['errorType'],expected_errorType,msg="[FAILED CHECK 4.1.2] ecs-updater aws boto3 params - Lambda Payload WRONG_IMAGE_NAME expected errorType")
            self.assertEqual(lambda_response_payload['errorMessage'],expected_error_message,msg="[FAILED CHECK 4.1.3] ecs-updater aws boto3 params - Lambda Payload WRONG_IMAGE_NAME expected error_message")

        # 4.2 Testing aws boto3 params SAME_INITIAL_VALUES
        with self.subTest(msg="4.2 Testing aws boto3 params SAME_INITIAL_VALUES"):

            # Loading testevent
            with open("lambda-ecs-updater.testevent-SAME_INITIAL_VALUES.json", "r", encoding='utf8') as testevent_file:
                testevent_text = testevent_file.read()

            # Running lambda function in aws
            lambda_response = lambda_client.invoke(
                FunctionName=TestECSUpdater.function_name,
                InvocationType='RequestResponse',
                Payload=testevent_text,
            )

            # Formating results
            lambda_response_payload = json.loads(lambda_response['Payload'].read())
            expected_BEFORE_image = "nginx"
            expected_BEFORE_tags = [{'key': 'updated-tag-name', 'value': 'updated-tag-value'}]
            expected_AFTER_image = "busybox"
            expected_AFTER_tags = [{'key': 'old-custom-tag-name', 'value': 'old-custom-tag-value'}]

            # Checking response
            self.assertEqual(lambda_response['ResponseMetadata']['HTTPStatusCode'],200,msg="[FAILED CHECK 4.2.1] ecs-updater aws boto3 params - Lambda Execution SAME_INITIAL_VALUES ResponseCode")
            self.assertEqual(lambda_response_payload['body']['BEFORE']['serviceImage'],expected_BEFORE_image,msg="[FAILED CHECK 4.2.2] ecs-updater aws boto3 params - Lambda Payload SAME_INITIAL_VALUES before Image")
            self.assertEqual(lambda_response_payload['body']['BEFORE']['tags'][0],expected_BEFORE_tags[0],msg="[FAILED CHECK 4.2.3] ecs-updater aws boto3 params - Lambda Payload SAME_INITIAL_VALUES before tags")
            self.assertEqual(lambda_response_payload['body']['AFTER']['serviceImage'],expected_AFTER_image,msg="[FAILED CHECK 4.2.4] ecs-updater aws boto3 params - Lambda Payload SAME_INITIAL_VALUES after Image")
            self.assertEqual(lambda_response_payload['body']['AFTER']['tags'][0],expected_AFTER_tags[0],msg="[FAILED CHECK 4.2.5] ecs-updater aws boto3 params - Lambda Payload SAME_INITIAL_VALUES after tags")


        # 4.3 Testing aws boto3 params MULTIPLE_TAGS
        with self.subTest(msg="4.3 Testing aws boto3 params MULTIPLE_TAGS"):

            # Loading testevent
            with open("lambda-ecs-updater.testevent-MULTIPLE_TAGS.json", "r", encoding='utf8') as testevent_file:
                testevent_text = testevent_file.read()

            # Running lambda function in aws
            lambda_response = lambda_client.invoke(
                FunctionName=TestECSUpdater.function_name,
                InvocationType='RequestResponse',
                Payload=testevent_text,
            )

            # Formating results
            lambda_response_payload = []
            lambda_response_payload = json.loads(lambda_response['Payload'].read())
            expected_AFTER_image = "nginx"
            expected_AFTER_tag_1 = [{'key': 'updated-tag-name-1', 'value': 'updated-tag-value-1'}]
            expected_AFTER_tag_2 = [{'key': 'updated-tag-name-2', 'value': 'updated-tag-value-2'}]

            # Checking response
            self.assertEqual(lambda_response['ResponseMetadata']['HTTPStatusCode'],200,msg="[FAILED CHECK 4.3.1] ecs-updater aws boto3 params - Lambda Execution MULTIPLE_TAGS ResponseCode")
            self.assertEqual(lambda_response_payload['body']['AFTER']['serviceImage'],expected_AFTER_image,msg="[FAILED CHECK 4.3.2] ecs-updater aws boto3 params - Lambda Execution MULTIPLE_TAGS Payload after Image")
            self.assertEqual(lambda_response_payload['body']['AFTER']['tags'][0],expected_AFTER_tag_1[0],msg="[FAILED CHECK 4.3.3] ecs-updater aws boto3 params - Lambda Execution MULTIPLE_TAGS after tag 1")
            self.assertEqual(lambda_response_payload['body']['AFTER']['tags'][1],expected_AFTER_tag_2[0],msg="[FAILED CHECK 4.3.4] ecs-updater aws boto3 params - Lambda Execution MULTIPLE_TAGS after tag 2")
