variable "environment" {
  description = "Environment name (e.g., dev, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

# Simplified subnet variables - one per subnet type
variable "public_subnets" {
  description = "Map of availability zones to public subnet CIDR blocks"
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.public_subnets) >= 0
    error_message = "Public subnets map must be valid."
  }
}

variable "private_subnets" {
  description = "Map of availability zones to private subnet CIDR blocks"
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.private_subnets) >= 0
    error_message = "Private subnets map must be valid."
  }
}

variable "database_subnets" {
  description = "Map of availability zones to database subnet CIDR blocks"
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.database_subnets) >= 0
    error_message = "Database subnets map must be valid."
  }
}

variable "management_subnets" {
  description = "Map of availability zones to management subnet CIDR blocks"
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.management_subnets) >= 0
    error_message = "Management subnets map must be valid."
  }
}

variable "enable_nat_gateway" {
  description = "Should be true to provision NAT Gateways for each of your private networks"
  type        = bool
  default     = true
}

variable "enable_vpn_gateway" {
  description = "Should be true to provision a VPN Gateway"
  type        = bool
  default     = false
}

variable "enable_dns_hostnames" {
  description = "Should be true to enable DNS hostnames in the VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Should be true to enable DNS support in the VPC"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Should be true to enable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_retention_days" {
  description = "Retention period for VPC Flow Logs in CloudWatch"
  type        = number
  default     = 14
  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
    ], var.flow_log_retention_days)
    error_message = "Flow log retention days must be a valid CloudWatch log retention period."
  }
}

variable "enable_vpc_endpoints" {
  description = "Should be true to enable VPC endpoints for AWS services"
  type        = bool
  default     = false
}

variable "single_nat_gateway" {
  description = "Should be true to provision a single shared NAT Gateway across all private networks"
  type        = bool
  default     = false
}

variable "one_nat_gateway_per_az" {
  description = "Should be true to provision only one NAT Gateway per availability zone"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to assign to the resource"
  type        = map(string)
  default     = {}
}

variable "app_port" {
  description = "Port number for the application"
  type        = number
  default     = 3000
  validation {
    condition     = var.app_port > 0 && var.app_port <= 65535
    error_message = "App port must be between 1 and 65535."
  }
}

variable "enable_rds" {
  description = "Should be true to create RDS security group"
  type        = bool
  default     = true
}

variable "db_port" {
  description = "Port number for the database (PostgreSQL)"
  type        = number
  default     = 5432
  validation {
    condition     = var.db_port > 0 && var.db_port <= 65535
    error_message = "Database port must be between 1 and 65535."
  }
}