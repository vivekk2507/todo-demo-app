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

variable "keypair_path" {
  description = "Path to the Jenkins key pair"
  type        = string
  default     = "/var/lib/jenkins/workspace/my-key.pub"
}

data "aws_key_pair" "existing_key" {
  key_name = "dummy_key_name"  # Just a dummy name since we're not using AWS key pair
  public_key = file(var.keypair_path)
}

resource "tls_private_key" "checkt" {
  count     = 1
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Security group for EC2 instance allowing SSH from Jenkins"

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

resource "aws_instance" "example" {
  ami             = "ami-0f58b397bc5c1f2e8"  # Replace with a valid Ubuntu AMI ID for ap-south-1
  instance_type   = var.instance_type
  key_name        = "dummy_key_name"  # Just a dummy name since we're not using AWS key pair
  security_groups = [aws_security_group.instance_sg.name]

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
      private_key = tls_private_key.checkt[0].private_key_pem
      host        = aws_instance.example.public_ip
    }
  }
}


