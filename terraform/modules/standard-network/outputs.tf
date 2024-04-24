output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "availability_zones" {
  value = data.aws_availability_zones.available.zone_ids
}

output "availability_zone_names" {
  value = data.aws_availability_zones.available.names
}

output "public_subnet_list" {
  value = [for subnet in aws_subnet.public : subnet.id]
}

