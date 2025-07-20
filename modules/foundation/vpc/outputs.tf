# VPC
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_arn" {
  description = "The ARN of the VPC"
  value       = aws_vpc.main.arn
}

output "vpc_cidr" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "vpc_instance_tenancy" {
  description = "Tenancy of instances spin up within VPC"
  value       = aws_vpc.main.instance_tenancy
}

output "vpc_enable_dns_support" {
  description = "Whether or not the VPC has DNS support"
  value       = aws_vpc.main.enable_dns_support
}

output "vpc_enable_dns_hostnames" {
  description = "Whether or not the VPC has DNS hostname support"
  value       = aws_vpc.main.enable_dns_hostnames
}

output "vpc_main_route_table_id" {
  description = "The ID of the main route table associated with this VPC"
  value       = aws_vpc.main.main_route_table_id
}

output "vpc_default_network_acl_id" {
  description = "The ID of the default network ACL"
  value       = aws_vpc.main.default_network_acl_id
}

output "vpc_default_security_group_id" {
  description = "The ID of the security group created by default on VPC creation"
  value       = aws_vpc.main.default_security_group_id
}

output "vpc_default_route_table_id" {
  description = "The ID of the default route table"
  value       = aws_vpc.main.default_route_table_id
}

# Internet Gateway
output "internet_gateway_id" {
  description = "The ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "internet_gateway_arn" {
  description = "The ARN of the Internet Gateway"
  value       = aws_internet_gateway.main.arn
}

# Public Subnets
output "public_subnet_ids" {
  description = "List of IDs of the public subnets"
  value       = values(aws_subnet.public)[*].id
}

output "public_subnet_arns" {
  description = "List of ARNs of the public subnets"
  value       = values(aws_subnet.public)[*].arn
}

output "public_subnet_cidr_blocks" {
  description = "List of CIDR blocks of the public subnets"
  value       = values(aws_subnet.public)[*].cidr_block
}

output "public_subnet_availability_zones" {
  description = "List of availability zones of the public subnets"
  value       = values(aws_subnet.public)[*].availability_zone
}

# Private Subnets
output "private_subnet_ids" {
  description = "List of IDs of the private subnets"
  value       = values(aws_subnet.private)[*].id
}

output "private_subnet_arns" {
  description = "List of ARNs of the private subnets"
  value       = values(aws_subnet.private)[*].arn
}

output "private_subnet_cidr_blocks" {
  description = "List of CIDR blocks of the private subnets"
  value       = values(aws_subnet.private)[*].cidr_block
}

output "private_subnet_availability_zones" {
  description = "List of availability zones of the private subnets"
  value       = values(aws_subnet.private)[*].availability_zone
}

# Database Subnets
output "database_subnet_ids" {
  description = "List of IDs of the database subnets"
  value       = values(aws_subnet.database)[*].id
}

output "database_subnet_arns" {
  description = "List of ARNs of the database subnets"
  value       = values(aws_subnet.database)[*].arn
}

output "database_subnet_cidr_blocks" {
  description = "List of CIDR blocks of the database subnets"
  value       = values(aws_subnet.database)[*].cidr_block
}

output "database_subnet_availability_zones" {
  description = "List of availability zones of the database subnets"
  value       = values(aws_subnet.database)[*].availability_zone
}

# Management Subnets
output "management_subnet_ids" {
  description = "List of IDs of the management subnets"
  value       = values(aws_subnet.management)[*].id
}

output "management_subnet_arns" {
  description = "List of ARNs of the management subnets"
  value       = values(aws_subnet.management)[*].arn
}

output "management_subnet_cidr_blocks" {
  description = "List of CIDR blocks of the management subnets"
  value       = values(aws_subnet.management)[*].cidr_block
}

output "management_subnet_availability_zones" {
  description = "List of availability zones of the management subnets"
  value       = values(aws_subnet.management)[*].availability_zone
}

# NAT Gateways
output "nat_gateway_ids" {
  description = "List of IDs of the NAT Gateways"
  value       = values(aws_nat_gateway.main)[*].id
}

output "nat_gateway_public_ips" {
  description = "List of public Elastic IPs associated with the NAT Gateways"
  value       = values(aws_eip.nat)[*].public_ip
}

output "nat_gateway_allocation_ids" {
  description = "List of allocation IDs of the Elastic IPs for the NAT Gateways"
  value       = values(aws_eip.nat)[*].id
}

# Route Tables
output "public_route_table_id" {
  description = "ID of the public route table"
  value       = length(aws_route_table.public) > 0 ? aws_route_table.public[0].id : null
}

output "private_route_table_ids" {
  description = "List of IDs of the private route tables"
  value       = values(aws_route_table.private)[*].id
}

output "database_route_table_ids" {
  description = "List of IDs of the database route tables"
  value       = values(aws_route_table.database)[*].id
}

output "management_route_table_ids" {
  description = "List of IDs of the management route tables"
  value       = values(aws_route_table.management)[*].id
}

# VPC Flow Logs
output "vpc_flow_log_id" {
  description = "The ID of the VPC Flow Log"
  value       = var.enable_flow_logs ? aws_flow_log.vpc_flow_log[0].id : null
}

output "vpc_flow_log_cloudwatch_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  value       = var.enable_flow_logs ? aws_cloudwatch_log_group.vpc_flow_log[0].name : null
}

# VPC Endpoints
output "vpc_endpoint_s3_id" {
  description = "The ID of VPC endpoint for S3"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.s3.id : null
}

output "vpc_endpoint_ecr_api_id" {
  description = "The ID of VPC endpoint for ECR API"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_api[0].id : null
}

output "vpc_endpoint_ecr_dkr_id" {
  description = "The ID of VPC endpoint for ECR Docker"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.ecr_dkr[0].id : null
}

output "vpc_endpoint_logs_id" {
  description = "The ID of VPC endpoint for CloudWatch Logs"
  value       = var.enable_vpc_endpoints ? aws_vpc_endpoint.logs[0].id : null
}
