# =====================================
# Public Route Table
# =====================================

resource "aws_route_table" "public" {
  count  = length(var.public_subnets) > 0 ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-public-rt"
    Type = "Public"
  })
}

resource "aws_route" "public_internet" {
  count                  = length(var.public_subnets) > 0 ? 1 : 0
  route_table_id         = aws_route_table.public[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

resource "aws_route_table_association" "public" {
  for_each = var.public_subnets

  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[0].id
}

# =====================================
# Private Route Tables (per AZ)
# =====================================

resource "aws_route_table" "private" {
  for_each = var.private_subnets

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-private-rt-${each.key}"
    Type = "Private"
    AZ   = each.key
  })
}

resource "aws_route" "private_nat" {
  for_each = var.enable_nat_gateway ? var.private_subnets : {}

  route_table_id         = aws_route_table.private[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.single_nat_gateway ? (
    aws_nat_gateway.main[keys(var.public_subnets)[0]].id
    ) : (
    aws_nat_gateway.main[each.key].id
  )
}

resource "aws_route_table_association" "private" {
  for_each = var.private_subnets

  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private[each.key].id
}

# =====================================
# Database Route Tables (per AZ, isolated)
# =====================================

resource "aws_route_table" "database" {
  for_each = var.database_subnets

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-database-rt-${each.key}"
    Type = "Database"
    AZ   = each.key
  })
}

resource "aws_route_table_association" "database" {
  for_each = var.database_subnets

  subnet_id      = aws_subnet.database[each.key].id
  route_table_id = aws_route_table.database[each.key].id
}

# =====================================
# Management Route Tables (sharing NAT Gateway with private subnets)
# =====================================

resource "aws_route_table" "management" {
  for_each = var.management_subnets

  vpc_id = aws_vpc.main.id

  tags = merge(var.tags, {
    Name = "${var.environment}-${var.app_name}-management-rt-${each.key}"
    Type = "Management"
    AZ   = each.key
  })
}

resource "aws_route" "management_nat" {
  for_each = var.enable_nat_gateway ? var.management_subnets : {}

  route_table_id         = aws_route_table.management[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id = var.single_nat_gateway ? (
    aws_nat_gateway.main[keys(var.public_subnets)[0]].id
    ) : (
    aws_nat_gateway.main[each.key].id
  )
}

resource "aws_route_table_association" "management" {
  for_each = var.management_subnets

  subnet_id      = aws_subnet.management[each.key].id
  route_table_id = aws_route_table.management[each.key].id
}
