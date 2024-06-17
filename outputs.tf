output "instance_public_ip" {
  description = "Public IP address of the deployed EC2 instance"
  value       = aws_instance.example.public_ip
}
output "public_key" {
  value = aws_key_pair.checkt.public_key
}
