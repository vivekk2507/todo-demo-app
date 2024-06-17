provider "aws" {
  region = var.region
}

# Create TLS private key
resource "tls_private_key" "checkt" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Save private key to a local file
resource "local_file" "private_key_pem" {
  content  = tls_private_key.checkt.private_key_pem
  filename = "${path.module}/checkt.pem"
}

# Create AWS key pair using the public key
resource "aws_key_pair" "checkt" {
  key_name   = var.keypair_name
  public_key = tls_private_key.checkt.public_key_openssh
}

# Output the path to the private key
output "private_key_path" {
  value = local_file.private_key_pem.filename
}
