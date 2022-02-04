
variable "ecs-updater-ecs-cluster_key_pair-name" {
  type = string
  default = "dummy-key-pair"
}

variable "ecs-updater-ecs-cluster_key_pair-key" {
  type = string
}

variable "ecs-updater-ecs-cluster_ecs_cluster-name" {
  type = string
  default = "ECSCluster"
}

variable "ecs-updater-ecs-cluster_launch_configuration-image_id" {
  type = string
  default = "ami-XXXX"
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
  default = ["subnet-c847e392","subnet-d4c3a99c","subnet-8fb228e9"]
}

variable "ecs-updater-ecs-cluster_iam_role-EC2Role-name" {
  type = string
  default = "EC2Role"
}

variable "ecs-updater-ecs-cluster_iam_role-AutoScalingRole-name" {
  type = string
  default = "AutoScalingRole"
}
