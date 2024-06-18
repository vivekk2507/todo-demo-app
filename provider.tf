provider "aws" {
  region = "ap-south-1"  # Replace with your desired AWS region
}

// Debugging AWS credentials
output "aws_credentials" {
  value = {
    access_key = aws_access_key.deployer.access_key
    secret_key = aws_access_key.deployer.secret_key
  }
}

    

