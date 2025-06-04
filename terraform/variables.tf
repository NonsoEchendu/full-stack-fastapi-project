variable "aws_region" {
  description = "The AWS region to deploy the resources"
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "The type of instance to deploy"
  type        = string
  default     = "t2.medium"
}

variable "instance_name" {
  description = "The name of the instance"
  type        = string
  default     = "cv-challenge"
}

variable "ami_id" {
  description = "The AMI ID to use for the instance"
  type        = string
  default     = "ami-084568db4383264d4"
}

variable "key_name" {
  description = "The key name to use for the instance"
  type        = string
  default     = "new-test-key-pair"
}

variable "private_key_path" {
  description = "The path to the key file"
  type        = string
  default     = "/home/vagrant/new-test-key-pair.pem"
}

variable "ssh_user" {
  description = "The SSH user to use for the instance"
  type        = string
  default     = "ubuntu"
}

variable "domain_name" {
  description = "The domain name to use for the instance"
  type        = string
  default     = "michaeloxo.tech"
}






