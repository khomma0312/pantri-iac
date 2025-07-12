# Public Subnets
resource "aws_subnet" "public" {
  for_each = var.availability_zones_and_public_subnet_cidrs

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

# Private Subnets
resource "aws_subnet" "private" {
  for_each = var.availability_zones_and_private_subnet_cidrs

  vpc_id            = aws_vpc.main.id
  cidr_block        = each.value
  availability_zone = "${data.aws_region.current.name}${each.key}"

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-private-subnet-${each.key}"
    Type = "Private"
    AZ   = each.key
  })
}