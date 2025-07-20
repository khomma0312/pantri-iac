module "consts" {
  source = "../../modules/shared/consts"
}

module "vpc" {
  source = "../../modules/foundation/vpc"

  environment = local.environment
  app_name    = local.app_name

  vpc_cidr           = local.vpc_cidr
  public_subnets     = local.public_subnets
  private_subnets    = local.private_subnets
  database_subnets   = local.database_subnets
  management_subnets = local.management_subnets
}

module "security_groups" {
  source = "../../modules/foundation/security-groups"

  environment = local.environment
  app_name    = local.app_name

  vpc_id   = module.vpc.vpc_id
  vpc_cidr = module.vpc.vpc_cidr

  app_port             = local.app_port
  db_port              = local.db_port
  enable_rds           = local.enable_rds
  enable_vpc_endpoints = local.enable_vpc_endpoints
}

# TODO: これから実装する他のモジュール
# - ecs
# - alb
# - s3
# - cognito
# - cloudfront
# - rds
