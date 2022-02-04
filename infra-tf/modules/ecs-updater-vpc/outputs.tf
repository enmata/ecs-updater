output "ecs-updater_vpc-vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "ecs-updater_vpc-public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}
