#*********************************
# Terraform State Storage
#*********************************
terraform {
  backend "s3" {
    region         = "eu-west-1"
    bucket         = "ecs-tf-state-nnaruka-ireland"
    key            = "ecs-tf-state-nnaruka-ireland.terraform.tfstate"
    encrypt        = true
    dynamodb_table = "tf-state-ecs-nnaruka"
  }
}



#*********************************
# VPC Setup
#*********************************

provider "aws" {
  region = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc-cidr
  enable_dns_hostnames = true
tags = {
    Name = "vpc"
    Owner = var.Owner
    Project = var.Project
  }
}

#*********************************
# Internet Gateway Setup
#*********************************

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
tags = {
    Name = "Internet Gateway"
    Owner = var.Owner
    Project = var.Project
  }
}
 
#*********************************
# Public and Private Subnet Setup
#*********************************

resource "aws_subnet" "public-subnet-01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-public-01
  availability_zone = "${var.region}a"
  tags = {
    Name = "public-subnet-01"
    Owner = var.Owner
    Project = var.Project
  }
}

resource "aws_subnet" "public-subnet-02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-public-02
  availability_zone = "${var.region}b"
tags = {
    Name = "public-subnet-02"
    Owner = var.Owner
    Project = var.Project
  }
}

resource "aws_subnet" "private-subnet-01" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-private-01
  availability_zone = "${var.region}a"
tags = {
    Name = "private-subnet-01"
    Owner = var.Owner
    Project = var.Project
  }
}

resource "aws_subnet" "private-subnet-02" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = var.subnet-cidr-private-02
  availability_zone = "${var.region}b"
tags = {
    Name = "private-subnet-02"
    Owner = var.Owner
    Project = var.Project
  }
}

#*********************************
# Nat Gateway Setup
#*********************************

resource "aws_eip" "nat01" {
  vpc = true
  tags = {
    Name = "ElasticIPForNatGw"
    Owner = var.Owner
    Project = var.Project
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.nat01.id
  subnet_id     = aws_subnet.public-subnet-01.id
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name = "NatGwPublic"
    Owner = var.Owner
    Project = var.Project
  }
}

#*********************************
# Route Table Setup
#*********************************


resource "aws_route_table" "public-subnet-route-table" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "Public Subnet Route"
    Owner = var.Owner
    Project = var.Project
  }
}



resource "aws_route" "public-subnet-route-igw" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public-subnet-route-table.id
}


resource "aws_route_table_association" "public-subnet-route-table-association-01" {
  subnet_id      = aws_subnet.public-subnet-01.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}

resource "aws_route_table_association" "public-subnet-route-table-association-02" {
  subnet_id      = aws_subnet.public-subnet-02.id
  route_table_id = aws_route_table.public-subnet-route-table.id
}




resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
  tags = {
    Name = "Private Route Table"
    Owner = var.Owner
    Project = var.Project
  }
}

resource "aws_route_table_association" "private01" {
  subnet_id      = aws_subnet.private-subnet-01.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private02" {
  subnet_id      = aws_subnet.private-subnet-02.id
  route_table_id = aws_route_table.private_route_table.id
}

#*********************************
# Key Pair
#*********************************


resource "aws_key_pair" "web" {
  key_name = "NareshNaruka"
  public_key = file(pathexpand(var.public_key))
}

#*********************************
# Jump Host
#*********************************


resource "aws_instance" "JumpHost" {
  ami                         = "ami-cdbfa4ab"
  instance_type               = "t2.small"
  vpc_security_group_ids      = [aws_security_group.jumphost-instance-security-group.id]
  subnet_id                   = aws_subnet.public-subnet-01.id
  associate_public_ip_address = true
  key_name                    = aws_key_pair.web.key_name
#  user_data                   = <<EOF
#!/bin/sh
#yum install -y nginx
#service nginx start
#EOF
tags = {
    Name = "Jump Host"
    Owner = var.Owner
    Project = var.Project
  }

}

#*********************************
# Security Grp 
#*********************************


resource "aws_security_group" "web-instance-security-group" {
  vpc_id = aws_vpc.vpc.id
  name = "SG TechTest 80 22"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "Web-instance-security-group"
    Owner = var.Owner
    Project = var.Project
  }
}

resource "aws_security_group" "jumphost-instance-security-group" {
  vpc_id = aws_vpc.vpc.id
  name = "TechTest 22"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
tags = {
    Name = "Jump Host Security Group"
    Owner = var.Owner
    Project = var.Project
  }
}


#*********************************
# Output
#*********************************

output "web_domain" {
  value = aws_instance.JumpHost.public_dns
}


