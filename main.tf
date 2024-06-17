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

variable "jenkins_ip" {
  description = "Jenkins' IP address for SSH access in CIDR notation (e.g., x.x.x.x/32)"
  type        = string
  default     = "43.204.143.128/32"
}

# Check if key pair exists
data "aws_key_pair" "existing_key" {
  key_name = "checkt"

  # Ignore errors if key pair doesn't exist
  depends_on = []
  lifecycle {
    ignore_errors = true
  }
}

# Create key pair if it doesn't exist
resource "tls_private_key" "example_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
  count     = data.aws_key_pair.existing_key.id != "" ? 0 : 1
}

resource "aws_key_pair" "example_key" {
  key_name   = "checkt"
  public_key = tls_private_key.example_key[0].public_key_openssh

  lifecycle {
    ignore_changes = [public_key]
  }

  count = data.aws_key_pair.existing_key.id != "" ? 0 : 1
}

# Check if security group exists
data "aws_security_group" "existing_sg" {
  filter {
    name   = "group-name"
    values = ["instance-sg"]
  }

  # Ignore errors if security group doesn't exist
  depends_on = []
  lifecycle {
    ignore_errors = true
  }
}

# Create security group if it doesn't exist
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for EC2 instance allowing SSH from Jenkins"

  lifecycle {
    ignore_changes = [tags]
  }

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

  count = data.aws_security_group.existing_sg.id != "" ? 0 : 1
}

resource "aws_instance" "example" {
  ami             = "ami-0f58b397bc5c1f2e8"  # Replace with a valid Ubuntu AMI ID for ap-south-1
  instance_type   = var.instance_type
  key_name        = data.aws_key_pair.existing_key.id != "" ? data.aws_key_pair.existing_key.key_name : aws_key_pair.example_key[0].key_name
  security_groups = [data.aws_security_group.existing_sg.id != "" ? data.aws_security_group.existing_sg.name : aws_security_group.instance_sg[0].name]

  lifecycle {
    ignore_changes = [tags]
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
      user        = "ubuntu"  # Replace with appropriate user for your AMI
      private_key = tls_private_key.example_key[0].private_key_pem
      host        = aws_instance.example.public_ip
    }
  }
}

