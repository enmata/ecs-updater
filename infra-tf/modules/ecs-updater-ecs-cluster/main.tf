
resource "aws_key_pair" "dummy-key-pair" {
  key_name   = var.ecs-updater-ecs-cluster_key_pair-name
  public_key = var.ecs-updater-ecs-cluster_key_pair-key
}

resource "aws_ecs_cluster" "ECSCluster" {
  name       = var.ecs-updater-ecs-cluster_ecs_cluster-name
}

resource "aws_launch_configuration" "LaunchConfiguration" {
  key_name             = aws_key_pair.dummy-key-pair.key_name
  image_id             = var.ecs-updater-ecs-cluster_launch_configuration-image_id
  security_groups      = [ aws_security_group.EcsHostSecurityGroup.id]
  instance_type        = var.ecs-updater-ecs-cluster_launch_configuration-instance_type
  iam_instance_profile = aws_iam_instance_profile.EC2InstanceProfile.id
  user_data            = <<-EOF
                          #!/bin/bash -xe
                          echo ECS_CLUSTER=${aws_ecs_cluster.ECSCluster.name} >> /etc/ecs/ecs.config
                          yum install -y aws-cfn-bootstrap
                          EOF
}

resource "aws_security_group" "EcsHostSecurityGroup" {
  vpc_id    = var.ecs-updater-ecs-cluster_security_group-vpc_id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

}

resource "aws_iam_instance_profile" "EC2InstanceProfile" {
  name = var.ecs-updater-ecs-cluster_iam_instance_profile-name
  role = aws_iam_role.EC2Role.name
}

resource "aws_iam_role" "EC2Role" {
  name = var.ecs-updater-ecs-cluster_iam_role-EC2Role-name
  path = "/"
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM", "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"]
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy" "EC2RolePolicy" {
  role        = aws_iam_role.EC2Role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ecs:CreateCluster",
          "ecs:DeregisterContainerInstance",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:RegisterContainerInstance",
          "ecs:StartTelemetrySession",
          "ecs:Submit*",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "ecr:GetAuthorizationToken",
          "ecr:BatchGetImage",
          "ecr:GetDownloadUrlForLayer"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_autoscaling_group" "ECSAutoScalingGroup" {
  max_size         = "2"
  min_size         = "1"
  desired_capacity = "1"
  vpc_zone_identifier = var.ecs-updater-ecs-cluster_autoscaling_group-vpc_zone_identifier
  launch_configuration = aws_launch_configuration.LaunchConfiguration.name
  health_check_type    = "EC2"
}

resource "aws_iam_role" "AutoScalingRole" {
  name = var.ecs-updater-ecs-cluster_iam_role-AutoScalingRole-name
  path = "/"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "application-autoscaling.amazonaws.com"
        }
      },
    ]
  })

}

resource "aws_iam_policy" "AutoScalingRolePolicy" {

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "application-autoscaling:*",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:PutMetricAlarm",
          "ecs:DescribeServices",
          "ecs:UpdateService"
        ]
        Effect   = "Allow"
        Resource = "*"
      },
    ]
  })
}
