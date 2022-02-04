
resource "aws_iam_role_policy" "Custom-PolicyLambdaECSUpdater" {
  name      = var.ecs-updater-ecs-cluster-lambda_role_name
  role      = aws_iam_role.RoleLambdaECSUpdater.id
  policy    = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:UpdateService",
          "ecs:RegisterTaskDefinition",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:UntagResource",
          "ecs:TagResource",
          "tag:UntagResources",
          "tag:TagResources"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role" "RoleLambdaECSUpdater" {
  name                = var.ecs-updater-ecs-cluster-lambda_role_name
  assume_role_policy  = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    ecs-updater-terraform = "ecs-updater-lambda"
  }
}

resource "aws_lambda_function" "LambdaECSUpdater" {
  function_name = var.ecs-updater-ecs-cluster-lambda_function_name
  filename      = var.ecs-updater-ecs-cluster-lambda_filename
  role          = aws_iam_role.RoleLambdaECSUpdater.arn
  handler       = "lambda-ecs-updater.lambda_handler"
  runtime       = "python3.9"
  reserved_concurrent_executions = 1
  timeout       = 30
  tags = {
    ecs-updater-terraform = "ecs-updater-lambda"
  }
}
