# Data source for current AWS region
data "aws_region" "current" {}

# =====================================
# Public Subnets
# =====================================

resource "aws_subnet" "public" {
  for_each = var.public_subnets

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = "${data.aws_region.current.name}${each.key}"
  map_public_ip_on_launch = true

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-public-subnet-${each.key}"
    Type = "Public"
    AZ   = each.key
  })
}

# =====================================
# Private Subnets
# =====================================

resource "aws_subnet" "private" {
  for_each = var.private_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${data.aws_region.current.name}${each.key}"

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-private-subnet-${each.key}"
    Type = "Private"
    AZ   = each.key
  })
}

# =====================================
# Database Subnets
# =====================================

resource "aws_subnet" "database" {
  for_each = var.database_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${data.aws_region.current.name}${each.key}"

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-database-subnet-${each.key}"
    Type = "Database"
    AZ   = each.key
  })
}

# =====================================
# Management Subnets
# =====================================

resource "aws_subnet" "management" {
  for_each = var.management_subnets

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${data.aws_region.current.name}${each.key}"

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-management-subnet-${each.key}"
    Type = "Management"
    AZ   = each.key
  })
}