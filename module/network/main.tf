resource "aws_vpc" "vpc" {
  cidr_block = var.cidr_block
  enable_dns_support = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames

  tags = {
    Name = var.tag
  }
}

resource "aws_eip" "eip" {
  vpc = true
  tags = {
    Name = var.tag
  }
  lifecycle {
    create_before_destroy = true
  }
}

// nat は今回は使用しない
// コスト的に片側にのみ
//resource "aws_nat_gateway" "nat_gw" {
//  allocation_id = aws_eip.for_nat.id
//  subnet_id = aws_subnet.public[0].id
//}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.tag
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = var.tag
  }
}

resource "aws_route" "public" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count = length(var.availability_zones)
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "public" {
  count = length(var.public_subnet_cidr)
  vpc_id = aws_vpc.vpc.id
  availability_zone = element(var.availability_zones, count.index)
  cidr_block = var.public_subnet_cidr[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.tag}-${substr(element(var.availability_zones, count.index), -1, 1)}" // tag-c, tag-d
  }
}

// 最小構成なので private subnet を設けない
//resource "aws_route_table" "private" {
//  count = length(var.availability_zones)
//  vpc_id = aws_vpc.vpc.id
//  tags = {
//    Name = var.tag
//  }
//}

//resource "aws_route" "private" {
//  count = length(var.availability_zones)
//  route_table_id = element(aws_route_table.private.*.id, count.index)
//  destination_cidr_block = "0.0.0.0/0"
//  nat_gateway_id = aws_nat_gateway.nat_gw.id
//}
//
//resource "aws_route_table_association" "private" {
//  count = length(var.availability_zones)
//  subnet_id = element(aws_subnet.private.*.id, count.index)
//  route_table_id = element(aws_route_table.private.*.id, count.index)
//}
//
//resource "aws_subnet" "private" {
//  count = length(var.availability_zones)
//  vpc_id = aws_vpc.vpc.id
//  availability_zone = element(var.availability_zones, count.index)
//  cidr_block = var.private_subnet[element(var.availability_zones, count.index)]
//  map_public_ip_on_launch = false
//  tags = {
//    Name = "${var.tag}-${substr(element(var.availability_zones, 1), -1, 1)}" // todo-d
//  }
//}
