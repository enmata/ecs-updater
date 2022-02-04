
variable "ecs-updater-ecs-cluster_key_pair-name" {
  type = string
  default = "dummy-key-pair"
}

variable "ecs-updater-ecs-cluster_key_pair-key" {
  type = string
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD3F6tyPEFEzV0LX3X8BsXdMsQz1x2cEikKDEY0aIj41qgxMCP/iteneqXSIFZBp5vizPvaoIR3Um9xK7PGoW8giupGn+EPuxIA4cDM4vzOqOkiMPhz5XK0whEjkVzTo4+S0puvDZuwIsdiW9mxhJc7tgBNL0cYlWSYVkz4G/fslNfRPW5mYAM49f4fhtxPb5ok4Q2Lg9dPKVHO/Bgeu5woMc7RY0p1ej6D4CKFE6lymSDJpW0YHX/wqE9+cfEauh7xZcG0q9t2ta6F6fmX0agvpFyZo8aFbXeUBr7osSCJNgvavWbM/06niWrOvYX2xwWdhXmXSrbX8ZbabVohBK41 email@example.com"
}

variable "ecs-updater-ecs-cluster_ecs_cluster-name" {
  type = string
  default = "ECSCluster"
}

variable "ecs-updater-ecs-cluster_launch_configuration-image_id" {
  type = string
  default = "ami-0236ff433d797a702"
}

variable "ecs-updater-ecs-cluster_launch_configuration-instance_type" {
  type = string
  default = "t2.small"
}

variable "ecs-updater-ecs-cluster_security_group-vpc_id" {
  type = string
  default = "vpc-XXXX"
}

variable "ecs-updater-ecs-cluster_iam_instance_profile-name" {
  type = string
  default = "EC2InstanceProfile"
}

variable "ecs-updater-ecs-cluster_autoscaling_group-vpc_zone_identifier" {
  type = list(string)
  default = ["subnet-XXXX","subnet-XXXX","subnet-XXXX"]
}

variable "ecs-updater-ecs-cluster_iam_role-EC2Role-name" {
  type = string
  default = "EC2Role"
}

variable "ecs-updater-ecs-cluster_iam_role-AutoScalingRole-name" {
  type = string
  default = "AutoScalingRole"
}

variable "ecs-updater-ecs-cluster-lambda_filename" {
  type = string
  default = "../lambda_code/ecs-updater-package.zip"
}

variable "ecs-updater-ecs-cluster-lambda_function_name" {
  type = string
  default = "ecs-updater"
}

variable "ecs-updater-ecs-cluster_lambda_function-role_name" {
  type = string
  default = "ecs-updater-lambda-role"
}

variable "ecs-updater-ecs-cluster_lambda_function-policy_name" {
  type = string
  default = "ecs-updater-function-policy"
}

variable "ecs-updater-vpc_name" {
  type = string
  default = "Production"
}

variable "ecs-updater-vpc_CIDR" {
  type = string
  default = "10.0.0.0/16"
}

variable "ecs-updater-vpc_Public-subnets-CIDR" {
  type = list(string)
  default = [ "10.0.0.0/24", "10.0.1.0/24" ]
}

variable "ecs-updater-vpc_Private-subnets-CIDR" {
  type = list(string)
  default = [ "10.0.2.0/24", "10.0.3.0/24" ]
}

variable "ecs-updater-vpc_region" {
  type = string
  default = "eu-west-1"
}

variable "ecs-updater-vpc_azs" {
  type = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
