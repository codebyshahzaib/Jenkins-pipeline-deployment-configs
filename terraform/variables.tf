variable "aws_region" {
  description = "AWS region in which to provision the instance"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR allowed to SSH to the instance; use the Jenkins public IP/32"
  type        = string
}