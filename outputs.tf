output "instance_public_ip" {
  description = "Public IP address of the deployed EC2 instance"
  value       = aws_instance.example.public_ip
}
output "private_key_path" {
  value = local_file.private_key_pem.filename
}
