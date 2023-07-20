resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "main"
  }
}

#Create a public subnet with CIDR block 10.0.1.0/24 in the above VPC.

resource "aws_subnet" "public_subnet" {
  vpc_id      = aws_vpc.main.id
  cidr_block  = "10.0.1.0/24"

  tags = {
    Name = "Public Subnet"
  }
}

#Create a private subnet with CIDR block 10.0.2.0/24 in the above VPC.

resource "aws_subnet" "private_subnet" {
  vpc_id      = aws_vpc.main.id
  cidr_block  = "10.0.2.0/24"
  availability-zone = ap-south-1

  tags = {
    Name = "Private Subnet"
  }
}

#Create an Internet Gateway (IGW) and attach it to the VPC.

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "igw"
  }
}

# Create a route table for the public subnet and associate it with the public subnet. 
#This route table should have a route to the Internet Gateway.

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block  = "0.0.0.0/0"
    gateway_id  = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "route-table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public.id
}


  #Security group: Allow SSH access from anywhere


  resource "aws_security_group" "ssh_access" {
   name_prefix = "ssh_access"
   vpc_id = aws_vpc.main.id
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
     protocol    = -1
     cidr_blocks = ["0.0.0.0/0"]
 }
 }

#Launch an EC2 instance in the public subnet with the following details:
#AMI
#Instance type: t2.micro

#User data: Use a shell script to install Apache and host a simple website

resource "aws_instance" "web_server" {
  ami                    = "ami-0f8ca728008ff5af4"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.ssh_access.id]


 user_data = <<-EOF
    #!/bin/bash

    # Update the package list
    sudo apt update

    # Install Apache
    sudo apt install -y apache2
    sudo cat <<HTML > /var/www/html/index.html
    <!DOCTYPE html>
    <html><body><h1>Welcome to my website</h1></body></html>
    HTML

    sudo systemctl restart apache2
  EOF

 tags = {
    Name = "terraform-instance"
  }
}


#Create an Elastic IP and associate it with the EC2 instance.

resource "aws_eip" "ip" {
   instance = aws_instance.server_terraform.id
   vpc      = true
   tags = {
     Name = "elastic-ip"
   }
 }