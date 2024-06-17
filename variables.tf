variable "jenkins_ip" {
  description = "Jenkins' IP address for SSH access in CIDR notation (e.g., x.x.x.x/32)"
  type        = string
  default     = "43.204.143.128/32"
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

variable "keypair_name" {
  description = "Name of the AWS key pair"
  type        = string
  default     = "checkt"  # Replace with the actual key pair name
}
