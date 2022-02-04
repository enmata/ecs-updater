
variable "ecs-updater-ecs-cluster-lambda_filename" {
  type = string
  default = "../../../lambda_code/ecs-updater-package.zip"
}

variable "ecs-updater-ecs-cluster-lambda_function_name" {
  type = string
  default = "ecs-updater"
}

variable "ecs-updater-ecs-cluster-lambda_role_name" {
  type = string
  default = "ecs-updater-lambda-role"
}

variable "ecs-updater-ecs-cluster-lambda_policy_name" {
  type = string
  default = "ecs-updater-function-policy"
}