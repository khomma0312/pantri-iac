# Get current AWS account ID
data "aws_caller_identity" "current" {}

# Get current AWS region
data "aws_region" "current" {}

# Generate random ID for unique resource naming
resource "random_id" "bucket_suffix" {
  byte_length = 4
}

# Get parameter store values for sensitive data
data "aws_ssm_parameter" "db_password" {
  name = "/pantri/${local.environment}/db/password"
}

# Get ECS optimized AMI
data "aws_ami" "ecs_optimized" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs-hvm-*-x86_64-ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
