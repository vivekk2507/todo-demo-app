variable "region" {
  description = "The AWS region to deploy the infrastructure"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to use"
  type        = string
}

variable "jenkins_ip" {
  description = "The IP address of the Jenkins server to allow SSH access"
  type        = string
}

variable "keypair_name" {
  description = "The name of the key pair"
  type        = string
}
