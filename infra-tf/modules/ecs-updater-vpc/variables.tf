
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

variable "ecs-updater-vpc_azs" {
  type = list(string)
  default = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
}
