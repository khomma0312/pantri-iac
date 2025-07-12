# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-igw"
  })
}

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  for_each = var.availability_zones_and_public_subnet_cidrs

  domain     = "vpc"
  depends_on = [aws_internet_gateway.main]

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-nat-eip-${each.key}"
    AZ   = each.key
  })
}

# NAT Gateways
resource "aws_nat_gateway" "main" {
  for_each = var.availability_zones_and_public_subnet_cidrs

  allocation_id = aws_eip.nat[each.key].id
  subnet_id     = aws_subnet.public[each.key].id

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-nat-gw-${each.key}"
    AZ   = each.key
  })

  depends_on = [aws_internet_gateway.main]
}