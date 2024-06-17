provider "aws" {
  region = var.region
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "keypair_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "my-keypair"
}

resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "keypair" {
  key_name   = var.keypair_name
  public_key = tls_private_key.keypair.public_key_openssh
}

resource "aws_security_group" "ssh" {
  name        = "ssh-access"
  description = "Allow SSH access from my IP"
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["43.204.143.128/32"]  # Replace with your IP address
  }
}

resource "aws_instance" "example" {
  ami             = "ami-0f58b397bc5c1f2e8"  # Replace with a valid AMI ID
  instance_type   = var.instance_type
  key_name        = aws_key_pair.keypair.key_name
  security_groups = [aws_security_group.ssh.name]

  tags = {
    Name = "example-instance"
  }
}


