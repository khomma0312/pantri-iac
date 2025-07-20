# ALB Security Group Outputs
output "alb_security_group_id" {
  description = "The ID of the security group for ALB"
  value       = aws_security_group.alb.id
}

output "alb_security_group_arn" {
  description = "The ARN of the security group for ALB"
  value       = aws_security_group.alb.arn
}

# ECS Security Group Outputs
output "ecs_security_group_id" {
  description = "The ID of the security group for ECS"
  value       = aws_security_group.ecs.id
}

output "ecs_security_group_arn" {
  description = "The ARN of the security group for ECS"
  value       = aws_security_group.ecs.arn
}

# RDS Security Group Outputs
output "rds_security_group_id" {
  description = "The ID of the security group for RDS"
  value       = var.enable_rds ? aws_security_group.rds[0].id : null
}

output "rds_security_group_arn" {
  description = "The ARN of the security group for RDS"
  value       = var.enable_rds ? aws_security_group.rds[0].arn : null
}

# VPC Endpoints Security Group Outputs
output "vpc_endpoints_security_group_id" {
  description = "The ID of the security group for VPC endpoints"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoints[0].id : null
}

output "vpc_endpoints_security_group_arn" {
  description = "The ARN of the security group for VPC endpoints"
  value       = var.enable_vpc_endpoints ? aws_security_group.vpc_endpoints[0].arn : null
}