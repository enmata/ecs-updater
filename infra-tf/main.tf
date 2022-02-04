module "ecs-updater-vpc" {
  source = "./modules/ecs-updater-vpc"

  ecs-updater-vpc_name                  = var.ecs-updater-vpc_name
  ecs-updater-vpc_CIDR                  = var.ecs-updater-vpc_CIDR
  ecs-updater-vpc_Public-subnets-CIDR   = var.ecs-updater-vpc_Public-subnets-CIDR
  ecs-updater-vpc_Private-subnets-CIDR  = var.ecs-updater-vpc_Private-subnets-CIDR
  ecs-updater-vpc_azs                   = ["${var.ecs-updater-vpc_region}a", "${var.ecs-updater-vpc_region}b", "${var.ecs-updater-vpc_region}c"]
}

module "ecs-updater-ecs-cluster" {
  source = "./modules/ecs-updater-ecs-cluster"

  ecs-updater-ecs-cluster_key_pair-name                         = var.ecs-updater-ecs-cluster_key_pair-name
  ecs-updater-ecs-cluster_key_pair-key                          = var.ecs-updater-ecs-cluster_key_pair-key
  ecs-updater-ecs-cluster_ecs_cluster-name                      = var.ecs-updater-ecs-cluster_ecs_cluster-name
  ecs-updater-ecs-cluster_launch_configuration-image_id         = var.ecs-updater-ecs-cluster_launch_configuration-image_id
  ecs-updater-ecs-cluster_launch_configuration-instance_type    = var.ecs-updater-ecs-cluster_launch_configuration-instance_type
  ecs-updater-ecs-cluster_security_group-vpc_id                 = module.ecs-updater-vpc.ecs-updater_vpc-vpc_id
  ecs-updater-ecs-cluster_iam_instance_profile-name             = var.ecs-updater-ecs-cluster_iam_instance_profile-name
  ecs-updater-ecs-cluster_autoscaling_group-vpc_zone_identifier = module.ecs-updater-vpc.ecs-updater_vpc-public_subnets
  ecs-updater-ecs-cluster_iam_role-EC2Role-name                 = var.ecs-updater-ecs-cluster_iam_role-EC2Role-name
  ecs-updater-ecs-cluster_iam_role-AutoScalingRole-name         = var.ecs-updater-ecs-cluster_iam_role-AutoScalingRole-name
}

module "ecs-updater-lambda" {
  source = "./modules/ecs-updater-lambda"

  ecs-updater-ecs-cluster-lambda_filename           = var.ecs-updater-ecs-cluster-lambda_filename
  ecs-updater-ecs-cluster-lambda_function_name      = var.ecs-updater-ecs-cluster-lambda_function_name
}

