###############################################
#   1. VPC
###############################################
resource "aws_vpc" "main" {
  cidr_block = var.vpc-cidr

  tags = {
    Name = "eks-vpc"
  }
}

###############################################
#   2. Internet Gateway
###############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "eks-IGW"
  }
}

###############################################
#   3. Web Public Subnets
###############################################
resource "aws_subnet" "web-public-subnet-1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr-block[0]
  availability_zone       = var.az[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-1"
  }
}

resource "aws_subnet" "web-public-subnet-2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.cidr-block[1]
  availability_zone       = var.az[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-public-subnet-2"
  }
}

###############################################
#   4. App Private Subnets
###############################################
resource "aws_subnet" "app-private-subnet-1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr-block[2]
  availability_zone = var.az[0]

  tags = {
    Name = "eks-private-subnet-1"
  }
}

resource "aws_subnet" "app-private-subnet-2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.cidr-block[3]
  availability_zone = var.az[1]

  tags = {
    Name = "eks-private-subnet-2"
  }
}
###############################################
#   6. Public Route Table
###############################################
resource "aws_route_table" "public-rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = var.rtb-cidr
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "eks-public-route-table"
  }
}

###############################################
#   7. Private Route Table
###############################################
resource "aws_route_table" "private-rtb" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = var.rtb-cidr
    nat_gateway_id = aws_nat_gateway.project-NAT.id
  }

  tags = {
    Name = "eks-private-route-table"
  }
}

###############################################
#   8. NAT Gateway
###############################################
resource "aws_eip" "EIP" {
  domain = var.eip-domain
}

resource "aws_nat_gateway" "project-NAT" {
  allocation_id = aws_eip.EIP.id
  subnet_id     = aws_subnet.web-public-subnet-1.id

  tags = {
    Name = "eks-project-NAT"
  }
}

###############################################
#   9. Route Table Associations
###############################################
resource "aws_route_table_association" "pub-1" {
  subnet_id      = aws_subnet.web-public-subnet-1.id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "pub-2" {
  subnet_id      = aws_subnet.web-public-subnet-2.id
  route_table_id = aws_route_table.public-rtb.id
}

resource "aws_route_table_association" "pri-1" {
  subnet_id      = aws_subnet.app-private-subnet-1.id
  route_table_id = aws_route_table.private-rtb.id
}

resource "aws_route_table_association" "pri-2" {
  subnet_id      = aws_subnet.app-private-subnet-2.id
  route_table_id = aws_route_table.private-rtb.id
}