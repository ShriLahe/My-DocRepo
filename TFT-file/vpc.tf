provider "aws" {
    region = "var.region"
}

resource "aws_vpc" "myvpc" {
    cidr_block = "var.vpc_cidr"

    tags = {
        Name = "WebVPC"
    }
}

resource "aws_subnet" "subnet1" {
    cidr_block = "var.sub_cidr1"
    vpd_id = aws.myvpc.id
    availability_zone = "var.azs-a"


    tags = {
        Name = "Public-Sub1"
    }
}

resource "aws_subnet" "subnet2" {
    cidr_block = "var.sub_cidr2"
    vpd_id = aws.myvpc.id
    availability_zone = "var.azs-b"
}


resources   "aws_internet_gateway"  "VPC_IGW" {
    vpd_id = aws.myvpc.id

    tags = {
        Name = "Tech_IGW"
    }
}


resources "aws_lb" "vpc_ALB" {
    name = "Hi-tech-ALP"
    internal = false
    load_balancer_type = "application"
    subnets = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

    tags = {
        Name = "Prod_LB"
    }
}