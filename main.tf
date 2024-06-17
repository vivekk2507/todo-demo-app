provider "aws" {
  region = var.region  # Use the region variable here
}

# Define input variables
variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-1"  # Default region
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"  # Default instance type
}

variable "jenkins_ip" {
  description = "Jenkins' IP address for SSH access in CIDR notation (e.g., x.x.x.x/32)"
  type        = string
  default     = "43.204.143.128/32"  # Replace with your Jenkins IP address in CIDR notation
}

# Generate SSH key pair
resource "tls_private_key" "example_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save the public key to a local file
resource "local_file" "public_key" {
  filename = "${path.module}/id_rsa.pub"
  content  = tls_private_key.example_key.public_key_openssh
}

# Create an AWS key pair using the generated SSH key, if it does not exist
resource "aws_key_pair" "example_key" {
  key_name   = "example-key"
  public_key = tls_private_key.example_key.public_key_openssh

  # Condition to create the key pair only if it does not already exist
  lifecycle {
    ignore_changes = [public_key]
  }

  # Only create the key pair if it does not exist
  count = length(aws_key_pair.example_key[*].key_name) == 0 ? 1 : 0
}

# Create a security group allowing SSH access from Jenkins IP, if it does not exist
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for EC2 instance allowing SSH from Jenkins"

  # Condition to create the security group only if it does not already exist
  lifecycle {
    ignore_changes = [tags]
  }

  # Only create the security group if it does not exist
  count = length(aws_security_group.instance_sg[*].name) == 0 ? 1 : 0

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.jenkins_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "InstanceSecurityGroup"
  }
}

# Launch an EC2 instance
resource "aws_instance" "example" {
  ami             = "ami-0f58b397bc5c1f2e8"  # Replace with a valid Ubuntu AMI ID for ap-south-1
  instance_type   = var.instance_type        # Use the variable for instance type
  key_name        = aws_key_pair.example_key.key_name
  security_groups = [aws_security_group.instance_sg.name]

  tags = {
    Name = "QuarkusAppInstance"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update -y",
      "sudo apt-get install -y openjdk-11-jdk wget tar",
      "wget -O /tmp/app.tar.gz https://github.com/vivekk2507/todo-demo-app/archive/refs/heads/main.tar.gz",
      "sudo mkdir -p /opt/app && sudo tar -xzvf /tmp/app.tar.gz -C /opt/app --strip-components=1",
      "cd /opt/app",
      "./mvnw package",
      "nohup java -jar target/quarkus-app/quarkus-run.jar &"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"  # Replace with the appropriate user for your AMI
      private_key = tls_private_key.example_key.private_key_pem
      host        = aws_instance.example.public_ip
    }
  }
}

