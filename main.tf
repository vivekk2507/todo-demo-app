# Creating key-pair on AWS using SSH-public key
resource "aws_key_pair" "deployer" {
  key_name   = var.key_name
  public_key = file("${path.module}/my-key.pub")

  lifecycle {
    prevent_destroy = true
  }
}

# Creating a security group to restrict/allow inbound connectivity
resource "aws_security_group" "network-security-group" {
  name        = var.network_security_group_name
  description = "Allow TLS inbound traffic"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nsg-inbound"
  }

  lifecycle {
    prevent_destroy = true
  }
}

# Creating Ubuntu EC2 instance
resource "aws_instance" "ubuntu-vm-instance" {
  ami                    = var.ubuntu_ami
  instance_type          = var.ubuntu_instance_type
  key_name               = aws_key_pair.deployer.key_name
  vpc_security_group_ids = [aws_security_group.network-security-group.id]

  tags = {
    Name = "ubuntu-vm"
  }
}

