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

# Create SSH key pair
resource "aws_key_pair" "example_keypair" {
  key_name   = "example-keypair"  # Replace with your desired key pair name
  public_key = file("~/.ssh/id_rsa.pub")  # Replace with the path to your SSH public key
}

# EC2 instance resource
resource "aws_instance" "example" {
  ami           = "ami-0f58b397bc5c1f2e8"  # Replace with a valid Ubuntu AMI ID for ap-south-1
  instance_type = var.instance_type       # Use the variable for instance type
  key_name      = aws_key_pair.example_keypair.key_name  # Reference the created SSH key pair

  tags = {
    Name = "QuarkusAppInstance"
  }

  # Provisioner block for remote execution
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
      private_key = file("~/.ssh/id_rsa")  # Replace with the path to your SSH private key
      host        = aws_instance.example.public_ip
    }
  }
}



