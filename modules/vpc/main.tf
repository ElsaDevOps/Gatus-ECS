terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}






resource "aws_vpc" "my_vpc" {
  cidr_block           = var.cidr_blockvpc
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.project_name}-vpc"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# Public subnets for ALB - needs internet access
resource "aws_subnet" "public_subnet" {
  for_each                = { for i, availability_zone in var.availability_zones : availability_zone => var.cidr_public_subnet_web[i] }
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = true

  tags = {
    Name        = "${var.project_name}-public-subnet"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}





# Private subnets for tasks - access via NAT gateway
resource "aws_subnet" "private_subnet_app" {
  for_each                = { for i, availability_zone in var.availability_zones : availability_zone => var.cidr_private_subnet_app[i] }
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = each.value
  availability_zone       = each.key
  map_public_ip_on_launch = false

  tags = {
    Name        = "${var.project_name}-private-subnet-app"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name        = "${var.project_name}-igw"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}




resource "aws_eip" "nat" {
  domain = "vpc"


  tags = {
    Name        = "${var.project_name}-nat-eip"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}


# NAT Gateway for private subnet outbound traffic (package updates, etc.)
resource "aws_nat_gateway" "nat_gateway" {
  availability_mode = "regional"
  allocation_id     = aws_eip.nat.id
  vpc_id            = aws_vpc.my_vpc.id


  tags = {
    Name        = "${var.project_name}-nat-gateway"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name        = "${var.project_name}-public-rt"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "public_default" {
  for_each               = aws_subnet.public_subnet
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id

  lifecycle {
    create_before_destroy = true
  }

}



resource "aws_route_table" "private_route_table" {
  for_each = aws_subnet.private_subnet_app
  vpc_id   = aws_vpc.my_vpc.id
  tags = {
    Name        = "${var.project_name}-private-rt-app"
    Project     = var.project_name
    Environment = "dev"
    ManagedBy   = "Terraform"
  }
}

resource "aws_route" "private_default" {
  for_each               = aws_subnet.private_subnet_app
  route_table_id         = aws_route_table.private_route_table[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id

}





resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public_subnet
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_app" {
  for_each       = aws_subnet.private_subnet_app
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private_route_table[each.key].id
}

