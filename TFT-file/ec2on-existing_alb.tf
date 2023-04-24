# Configure the AWS provider
provider "aws" {
  region = "us-west-2"
}

# Define the data source for the existing Application Load Balancer
data "aws_lb" "alb" {
  name = "my-alb"
}

# Create a security group for the EC2 instances
resource "aws_security_group" "ec2_sg" {
  name_prefix = "ec2_sg_"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create the EC2 instances
resource "aws_instance" "ec2" {
  count = 5
  ami = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  subnet_id = "subnet-0123456789abcdef0"
  security_group_ids = [aws_security_group.ec2_sg.id]
  key_name = "my-key-pair"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello from EC2 instance ${count.index + 1}"
              EOF
  tags = {
    Name = "EC2 Instance ${count.index + 1}"
  }
}

# Register the EC2 instances with the Application Load Balancer
resource "aws_lb_target_group_attachment" "ec2_attachment" {
  target_group_arn = data.aws_lb.alb.arn
  count            = 5
  target_id        = aws_instance.ec2[count.index].id
  port             = 80
}


#Explanation:
#
#provider "aws": Defines the AWS provider to use and sets the region to us-west-2.
#data "aws_lb" "alb": Defines a data source to retrieve information about the existing Application Load Balancer named my-alb.
#resource "aws_security_group" "ec2_sg": Creates a security group named ec2_sg_* for the EC2 instances, allowing incoming traffic on port 80.
#resource "aws_instance" "ec2": Creates 5 EC2 instances with the specified AMI, instance type, subnet, security group, key pair, and user data. Also adds tags to each instance with a name of EC2 Instance N, where N is the index of the instance in the count.
#resource "aws_lb_target_group_attachment" "ec2_attachment": Registers each EC2 instance with the Application Load Balancer specified in the data.aws_lb.alb data source. The attachment uses the EC2 instance ID and port 80, and is repeated for each EC2 instance using the count parameter.