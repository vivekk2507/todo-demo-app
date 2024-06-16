provider "aws" {
  region = "ap-south-1"
}

# Define input variables
variable "region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
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

# Use the generated key in AWS instance
resource "aws_instance" "example" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Replace with a valid Ubuntu AMI ID for ap-south-1
  instance_type = var.instance_type  # Use the variable for instance type

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
      user        = "ubuntu"
      private_key = tls_private_key.example_key.private_key_pem
      host        = aws_instance.example.public_ip
    }
  }
}


