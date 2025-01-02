# VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "login-vpc"
  }
}

# Frontend Subnet
resource "aws_subnet" "fe-sn" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "login-frontend-subnet"
  }
}

# Backend Subnet
resource "aws_subnet" "be-sn" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "login-backend-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "db-sn" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "login-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "login-internet-gateway"
  }
}

# Public Route Table
resource "aws_route_table" "pub-rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "login-public-rt"
  }
}

# Frontend Subnet Association 
resource "aws_route_table_association" "fe-sn-asc" {
  subnet_id      = aws_subnet.fe-sn.id
  route_table_id = aws_route_table.pub-rt.id
}

# Backend Subnet Association 
resource "aws_route_table_association" "be-sn-asc" {
  subnet_id      = aws_subnet.be-sn.id
  route_table_id = aws_route_table.pub-rt.id
}

# Private Route Table
resource "aws_route_table" "pvt-rt" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "login-private-rt"
  }
}

# Frontend Subnet Association 
resource "aws_route_table_association" "db-sn-asc" {
  subnet_id      = aws_subnet.db-sn.id
  route_table_id = aws_route_table.pvt-rt.id
}