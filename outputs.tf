output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "public_tier_subnet" {
  value = local.public_tier_subnet
}

output "private_tier_subnet" {
  value = local.private_tier_subnet
}

output "secure_tier_subnet" {
  value = local.secure_tier_subnet
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "private_subnet_ids" {
  value = aws_subnet.private.*.id
}

output "secure_subnet_ids" {
  value = aws_subnet.secure.*.id
}

output "public_route_table_ids" {
  value = aws_route_table.public.*.id
}

output "private_route_table_ids" {
  value = aws_route_table.private.*.id
}

output "vpc_custom_endpoint_dns_entries" {
  value = { for k, v in aws_vpc_endpoint.vpc_custom_endpoint : k => aws_vpc_endpoint.vpc_custom_endpoint[k].dns_entry }
}

output "secure_db_subnet_group_id" {
  value = length(aws_db_subnet_group.main) > 0 ? aws_db_subnet_group.main[0].id : ""
}

output "vpc_endpoints_ids" {
  value = { for k, v in aws_vpc_endpoint.vpc_endpoint : k => aws_vpc_endpoint.vpc_endpoint[k].id }
}

output "vpc_endpoint_dns_entries" {
  value = { for k, v in aws_vpc_endpoint.vpc_endpoint : k => aws_vpc_endpoint.vpc_endpoint[k].dns_entry }
}
