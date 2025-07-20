output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "ecs_security_group_id" {
  description = "ECS Security Group ID"
  value       = module.security_groups.ecs_security_group_id
}
