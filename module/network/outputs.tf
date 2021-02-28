output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "vpc_availability_zones" {
  value = var.availability_zones
}

output "vpc_cidr" {
  value = aws_vpc.vpc.cidr_block
}

output "public_subnet_ids" {
  value = aws_subnet.public.*.id
}

output "public_subnet_cidrs" {
  value = aws_subnet.public.*.cidr_block
}

output "eip_id" {
  value = aws_eip.eip.id
}