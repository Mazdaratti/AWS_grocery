variable "base_ami_id" {
  description = "The base AMI ID to use for the EC2 instance."
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instance."
  type        = string
}

variable "key_name" {
  description = "The key pair name for SSH access."
  type        = string
}

variable "subnet_id" {
  description = "The subnet ID where the EC2 instance will be launched."
  type        = string
}

variable "security_group_id" {
  description = "The security group ID for the EC2 instance."
  type        = string
}

variable "iam_instance_profile_name" {
  description = "The IAM instance profile name for the EC2 instance."
  type        = string
}

variable "private_key_path" {
  description = "The path to the private key for SSH access."
  type        = string
}

variable "region" {
  description = "The AWS region."
  type        = string
}

variable "ecr_registry_url" {
  description = "The ECR registry base URL for Docker login."
  type        = string
}

variable "frontend_image" {
  description = "The ECR repository URL for the frontend image."
  type        = string
}

variable "backend_image" {
  description = "The ECR repository URL for the backend image."
  type        = string
}