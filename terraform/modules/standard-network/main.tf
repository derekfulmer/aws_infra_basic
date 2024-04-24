######
# Discover available zones from the cidr
data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azcount  = length(data.aws_availability_zones.available.zone_ids)
  zone_ids = data.aws_availability_zones.available.zone_ids
}

######
# VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"
  tags = {
    Name    = "${var.stack_name}-vpc"
    ztgate = "true"
  }
}

######
# IGW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${var.stack_name}-igw"
  }
}

######
# Subnets
######
# Create the public subnets
resource "aws_subnet" "public" {
  for_each             = toset(local.zone_ids)
  vpc_id               = aws_vpc.vpc.id
  cidr_block           = cidrsubnet(var.cidr, 8, substr(each.value, -1, 1))
  availability_zone_id = each.value
  tags                 = {
    Name       = "${var.stack_name}-public-${each.value}"
    local_cidr = cidrsubnet(var.cidr, 8, substr(each.value, -1, 1))
  }
}



######
# Route Tables

# Public
resource "aws_route_table" "public_rts" {
  for_each = toset(local.zone_ids)
  vpc_id   = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "${var.stack_name}-public_rt-${each.value}"
  }
}

#######
# Endpoints for Route Tables
resource "aws_vpc_endpoint" "s3endpoint" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint_route_table_association" "s3endpoint_to_pubs" {
  for_each        = toset(local.zone_ids)
  route_table_id  = aws_route_table.public_rts[each.value].id
  vpc_endpoint_id = aws_vpc_endpoint.s3endpoint.id
}

resource "aws_vpc_endpoint" "dynendpoint" {
  vpc_id       = aws_vpc.vpc.id
  service_name = "com.amazonaws.${var.region}.dynamodb"
}

resource "aws_vpc_endpoint_route_table_association" "dynendpoint_to_pubs" {
  for_each        = toset(local.zone_ids)
  route_table_id  = aws_route_table.public_rts[each.value].id
  vpc_endpoint_id = aws_vpc_endpoint.dynendpoint.id
}

#######
# Route Table Associations
# This should eventually be converted to a loop over certain subnets

resource "aws_route_table_association" "rta_public" {
  for_each       = toset(local.zone_ids)
  route_table_id = aws_route_table.public_rts[each.value].id
  subnet_id      = aws_subnet.public[each.value].id
}


