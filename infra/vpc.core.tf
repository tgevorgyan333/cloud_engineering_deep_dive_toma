resource "aws_vpc" "core" {
  cidr_block           = local.core_vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name = "${terraform.workspace}-core-vpc"
  }
}


# 10.0.0.0   : Network Address (reserved)
# 10.0.0.1   : VPC Router (reserved)
# 10.0.0.2   : DNS Server (reserved)
# 10.0.0.3   : Future Use (reserved)
# 10.0.0.4   : First usable IP address
# ...
# 10.0.0.254 : Last usable IP address
# 10.0.0.255 : Network Broadcast Address (reserved)
# Each subnet will have 251 usable IP addresses.
resource "aws_subnet" "core_private" {
  for_each = {
    for idx in range(local.core_az_count) :
    "subnet-private-${local.az_suffix[idx]}" => {
      cidr_block        = cidrsubnet(local.core_vpc_cidr, 8, idx)
      availability_zone = "${local.core_region}${local.az_suffix[idx]}"
    }
  }

  vpc_id            = aws_vpc.core.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${terraform.workspace}-core-${each.key}"
  }
}



resource "aws_subnet" "core_public" {
  for_each = {
    for idx in range(local.core_az_count) :
    "subnet-public-${local.az_suffix[idx]}" => {
      cidr_block        = cidrsubnet(local.core_vpc_cidr, 8, idx + local.core_az_count + 10)
      availability_zone = "${local.core_region}${local.az_suffix[idx]}"
    }
  }

  vpc_id            = aws_vpc.core.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${terraform.workspace}-core-${each.key}"
  }
}
