locals {
  environment = module.consts.env_name_dev
  main_region = module.consts.main_region
  app_name    = module.consts.app_name

  # Common tags applied to all resources
  common_tags = {
    Project     = local.app_name
    Environment = local.environment
    ManagedBy   = "terraform"
  }

  # Resource naming convention
  name_prefix = "${local.app_name}-${local.environment}"

  # Network configuration
  vpc_cidr           = "10.0.0.0/16"
  availability_zones = ["a", "c"]

  # Simplified subnet configurations
  public_subnets = {
    a = "10.0.10.0/24"
    c = "10.0.20.0/24"
  }

  private_subnets = {
    a = "10.0.30.0/24"
    c = "10.0.40.0/24"
  }

  database_subnets = {
    a = "10.0.50.0/24"
    c = "10.0.60.0/24"
  }

  management_subnets = {
    a = "10.0.70.0/24"
    c = "10.0.80.0/24"
  }

  # Environment-specific settings
  is_production = local.environment == module.consts.env_name_prd

  # Database configuration
  db_backup_retention_period = local.is_production ? 7 : 1
  db_backup_window           = "03:00-04:00"
  db_maintenance_window      = "sun:04:00-sun:05:00"

  # ECS configuration
  ecs_min_capacity = local.is_production ? 2 : 1
  ecs_max_capacity = local.is_production ? 10 : 3

  # CloudWatch log retention
  log_retention_days = local.is_production ? 30 : 7

  # S3 bucket name (must be globally unique)
  s3_bucket_name = "${local.name_prefix}-static-assets-${random_id.bucket_suffix.hex}"

  # Application and database ports
  app_port = 3000
  db_port  = 5432

  # Feature flags
  enable_rds           = true
  enable_vpc_endpoints = true

  # Domain and SSL certificate configuration
  domain_name = var.domain_name

  # CloudFront certificate SANs (public-facing domains)
  cloudfront_sans = [
    "www.${local.domain_name}"
  ]

  # ALB certificate SANs (internal API domains)
  alb_sans = [
    "alb.${local.domain_name}"
  ]

  ecs_task_cpu      = 256
  ecs_task_memory   = 512
  ecs_desired_count = 1

  db_instance_class    = "db.t3.micro"
  db_allocated_storage = 20
  db_name              = "pantri"
}
