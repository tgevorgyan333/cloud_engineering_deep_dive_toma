resource "aws_vpc" "main" {
  cidr_block           = local.main_vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "network" {
  count             = local.main_az_count
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(local.main_vpc_cidr, 8, count.index)
  availability_zone = "${local.main_region}${local.az_suffix[count.index]}"

  tags = {
    Name = "main-subnet-private-${local.az_suffix[count.index]}"
  }
}

resource "aws_ec2_transit_gateway" "main" {
  description = "Main Transit Gateway"
  tags = {
    Name = "main-tgw"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "network" {
  subnet_ids         = aws_subnet.network[*].id
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = aws_vpc.main.id
  tags = {
    Name = "tgw-network-attachment"
  }
}


resource "aws_ec2_transit_gateway_vpc_attachment" "project_vpcs" {
  for_each = toset(local.core_workspaces)

  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = local.core_vpc_ids[each.key]
  subnet_ids         = local.core_private_subnet_ids[each.key]

  tags = {
    Name = "tgw-${each.key}-attachment"
  }
}






