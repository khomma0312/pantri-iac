# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-igw"
  })
}

# Determine which AZs need NAT Gateways
locals {
  nat_gateway_azs = var.single_nat_gateway ? (
    length(var.public_subnets) > 0 ? toset([keys(var.public_subnets)[0]]) : toset([])
  ) : (
    toset(keys(var.public_subnets))
  )
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.enable_nat_gateway ? local.nat_gateway_azs : toset([])

  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-nat-eip-${each.key}"
    AZ   = each.key
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  for_each = var.enable_nat_gateway ? local.nat_gateway_azs : toset([])

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-nat-gw-${each.key}"
    AZ   = each.key
  })

  depends_on = [aws_internet_gateway.main]
}