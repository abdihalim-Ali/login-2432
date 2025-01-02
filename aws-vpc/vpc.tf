# VPC
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"

  tags = {
    Name = "lms-vpc"
  }
}

# Frontend Subnet
resource "aws_subnet" "fe-sn" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "lms-frontend-subnet"
  }
}

# Backend Subnet
resource "aws_subnet" "be-sn" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "lms-backend-subnet"
  }
}

# Database Subnet
resource "aws_subnet" "db-sn" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "false"

  tags = {
    Name = "lms-database-subnet"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "lms-internet-gateway"
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
    Name = "lms-public-rt"
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
    Name = "lms-private-rt"
  }
}

# Frontend Subnet Association 
resource "aws_route_table_association" "db-sn-asc" {
  subnet_id      = aws_subnet.db-sn.id
  route_table_id = aws_route_table.pvt-rt.id
}

# NACL
resource "aws_network_acl" "nacl" {
  vpc_id = aws_vpc.vpc.id

  egress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 65535
  }

  tags = {
    Name = "lms-nacl"
  }
}

# Frontend Subnet Association
resource "aws_network_acl_association" "fe-nacl-asc" {
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.fe-sn.id
}

# Backend Subnet Association
resource "aws_network_acl_association" "be-nacl-asc" {
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.be-sn.id
}

# Database Subnet Association
resource "aws_network_acl_association" "db-nacl-asc" {
  network_acl_id = aws_network_acl.nacl.id
  subnet_id      = aws_subnet.db-sn.id
}

# Frontend Security Group
resource "aws_security_group" "fe-sg" {
  name        = "frontend-firewall"
  description = "Allow frontend traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "frontend-firewall"
  }
}

resource "aws_vpc_security_group_ingress_rule" "fe-sg-ssh" {
  security_group_id = aws_security_group.fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "fe-sg-http" {
  security_group_id = aws_security_group.fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "fe-sg-ob" {
  security_group_id = aws_security_group.fe-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Backend Security Group
resource "aws_security_group" "be-sg" {
  name        = "backend-firewall"
  description = "Allow backend traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "backend-firewall"
  }
}

resource "aws_vpc_security_group_ingress_rule" "be-sg-ssh" {
  security_group_id = aws_security_group.be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "be-sg-http" {
  security_group_id = aws_security_group.be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 8080
  ip_protocol       = "tcp"
  to_port           = 8080
}

resource "aws_vpc_security_group_egress_rule" "be-sg-ob" {
  security_group_id = aws_security_group.be-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

# Database Security Group
resource "aws_security_group" "db-sg" {
  name        = "database-firewall"
  description = "Allow database traffic"
  vpc_id      = aws_vpc.vpc.id

  tags = {
    Name = "database-firewall"
  }
}

resource "aws_vpc_security_group_ingress_rule" "db-sg-ssh" {
  security_group_id = aws_security_group.db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_ingress_rule" "db-sg-postgres" {
  security_group_id = aws_security_group.db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}

resource "aws_vpc_security_group_egress_rule" "db-sg-ob" {
  security_group_id = aws_security_group.db-sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}