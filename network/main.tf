# VPC
resource "aws_vpc" "cloudgen" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.cloudgen.id
  cidr_block              = "10.0.0.0/24"
  availability_zone       = var.availability_zone
}

# Internet Gateway
resource "aws_internet_gateway" "cloudgen_igw" {
  vpc_id = aws_vpc.cloudgen.id
}

# Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.cloudgen.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.cloudgen_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

# Subnet Association for Public Subnet
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# Security Group for EC2 Instances in Public Subnet
resource "aws_security_group" "public_security_group" {
  vpc_id = aws_vpc.cloudgen.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.cloudgen.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = var.availability_zone
}

# Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.cloudgen.id

  tags = {
    Name = "private_route_table"
  }
}

# Subnet Association for Private Subnet
resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# Security Group for RDS Instance in Private Subnet
resource "aws_security_group" "private_security_group" {
  vpc_id = aws_vpc.cloudgen.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.public_security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# NAT Gateway
resource "aws_nat_gateway" "cloudgen_nat_gateway" {
  allocation_id = aws_eip.cloudgen_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# EIP for NAT Gateway
resource "aws_eip" "cloudgen_eip" {
  vpc = true
}

# Route Table for Private Subnet with NAT Gateway
resource "aws_route_table" "private_route_table_nat" {
  vpc_id = aws_vpc.cloudgen.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.cloudgen_nat_gateway.id
  }

  tags = {
    Name = "private_route_table_nat"
  }
}

# Subnet Association for Private Subnet with NAT Gateway
resource "aws_route_table_association" "private_route_table_nat_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table_nat.id
}
