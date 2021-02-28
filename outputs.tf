output "vpc_id" {
  value = module.network.vpc_id
}

output "vpc_availability_zones" {
  value = module.network.vpc_availability_zones
}

output "vpc_cidr" {
  value = module.network.vpc_cidr
}

output "public_subnet_ids" {
  value = module.network.public_subnet_ids
}

output "public_subnet_cidrs" {
  value = module.network.public_subnet_cidrs
}

output "eip_id" {
  value = module.network.eip_id
}

output "instance_id" {
  value = module.ec2.instance_id
}
