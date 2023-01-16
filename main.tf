# Terraform main.tf

# root/Providers.tf

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "new-vpc" {
  cidr_block           = "172.17.0.0/16"
  tags = {
    Name = "new-vpc"
  }
}

# Create a Internet Gateway
resource "aws_internet_gateway" "new-igw" {
  vpc_id = aws_vpc.new-vpc.id
  tags = {
    Name = "new-igw"
  }
}

# Create a Route Table
resource "aws_route_table" "new-route-table" {
  vpc_id = aws_vpc.new-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new-igw.id
  }
  tags = {
    Name = "new-route-table"
  }
}

# Create Public and Private Subnets
resource "aws_subnet" "new-public-subnet-1" {
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "172.17.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "new-public-subnet-1"
  }
}

resource "aws_subnet" "new-public-subnet-2" {
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "172.17.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "new-public-subnet-2"
  }
}

resource "aws_subnet" "new-private-subnet-1" {
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "172.17.3.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1a"
  tags = {
    Name = "new-private-subnet-1"
  }
}

resource "aws_subnet" "new-private-subnet-2" {
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "172.17.4.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"
  tags = {
    Name = "new-private-subnet-2"
  }
}

resource "aws_subnet" "new-private-subnet-3" {
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "172.17.5.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1c"
  tags = {
    Name = "new-private-subnet-3"
  }
}

resource "aws_subnet" "new-private-subnet-4" {
  vpc_id                  = aws_vpc.new-vpc.id
  cidr_block              = "172.17.6.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1d"
  tags = {
    Name = "new-private-subnet-4"
  }
}

# Route Associations for public subnets
resource "aws_route_table_association" "new-route-1a" {
  subnet_id      = aws_subnet.new-public-subnet-1.id
  route_table_id = aws_route_table.new-route-table.id
}
resource "aws_route_table_association" "new-route-2b" {
  subnet_id      = aws_subnet.new-public-subnet-2.id
  route_table_id = aws_route_table.new-route-table.id
}

# Web tier Security Group
resource "aws_security_group" "web-server-sg" {
  name        = "web_sg"
  description = "Enable HTTP and SSH access to ec2 instances"
  vpc_id      = aws_vpc.new-vpc.id

  #Allow SSH access.
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow incoming HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  # Allow outgoing--access to web.
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Database tier Security gruop
resource "aws_security_group" "database-sg" {
  name        = "database_sg"
  description = "allow traffic from internet"
  vpc_id      = aws_vpc.new-vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}