provider "aws" {
  access_key = "*******"
  secret_key = "***********"
  region     = "us-east-1"
}

## Create VPC ##
resource "aws_vpc" "terraform-vpc" {
  cidr_block           = "172.16.0.0/16"
  enable_dns_hostnames = true
  tags = {
    Name = "terraform-vpc"
  }
}

output "aws_vpc_id" {
  value = aws_vpc.terraform-vpc.id
}

## Security Group##
resource "aws_security_group" "terraform_private_sg" {
  description = "Allow limited inbound external traffic"
  vpc_id      = aws_vpc.terraform-vpc.id
  name        = "terraform_ec2_private_sg"

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 22
    to_port     = 22
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 8080
    to_port     = 8080
  }

  ingress {
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 443
    to_port     = 443
  }

  egress {
    protocol    = -1
    cidr_blocks = ["0.0.0.0/0"]
    from_port   = 0
    to_port     = 0
  }

  tags = {
    Name = "terraform-sg"
  }
}

output "aws_security_gr_id" {
  value = aws_security_group.terraform_private_sg.id
}

## Create Subnets ##
resource "aws_subnet" "terraform-subnet_1" {
  vpc_id            = aws_vpc.terraform-vpc.id
  cidr_block        = "172.16.10.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "terraform-subnet"
  }
}
output "aws_subnet_subnet_1" {
  value = aws_subnet.terraform-subnet_1.id
}

## Create Instance ##
resource "aws_instance" "terraform_wapp" {
  ami                         = "ami-0022f774911c1d690"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.terraform_private_sg.id}"]
  subnet_id                   = aws_subnet.terraform-subnet_1.id
  count                       = 1
  associate_public_ip_address = true
  tags = {
    Name        = "terraform-ec2-vpc"
  }
}

output "instance_id_list" { value = ["${aws_instance.terraform_wapp.*.id}"] }
