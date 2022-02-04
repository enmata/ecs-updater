
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.0"

  name = var.ecs-updater-vpc_name
  cidr = var.ecs-updater-vpc_CIDR

  azs = var.ecs-updater-vpc_azs

  private_subnets = var.ecs-updater-vpc_Private-subnets-CIDR
  public_subnets  = var.ecs-updater-vpc_Public-subnets-CIDR

  enable_dns_support = true
  enable_dns_hostnames = true
  instance_tenancy = "default"

  single_nat_gateway   = true
  enable_nat_gateway   = true
  enable_vpn_gateway   = false

  public_subnet_tags = {
    Name = "public"
    ecs-updater-terraform = "ecs-updater-vpc"
  }

  private_subnet_tags = {
    Name = "private"
    ecs-updater-terraform = "ecs-updater-vpc"
  }

  public_route_table_tags = {
    Name = "public-RT"
    ecs-updater-terraform = "ecs-updater-vpc"
  }

  private_route_table_tags = {
    Name = "private-RT"
    ecs-updater-terraform = "ecs-updater-vpc"
  }

  tags = {
    ecs-updater-terraform = "ecs-updater-vpc"
  }
}
