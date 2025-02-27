variable "cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
}

variable "task_family" {
  description = "Family name for the ECS task definition"
  type        = string
}

variable "container_name" {
  description = "Name of the container"
  type        = string
}

variable "container_image" {
  description = "Docker image for the container"
  type        = string
}

variable "container_port" {
  description = "Port on which the container listens"
  type        = number
}

variable "desired_count" {
  description = "Number of tasks to run"
  type        = number
}

variable "target_group_arn" {
  description = "ARN of the ALB target group"
  type        = string
}

variable "ecs_security_group_id" {
  description = "Security group ID for ECS instances"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ECS instances"
  type        = list(string)
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name for ECS instances"
  type        = string
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2."
  type        = string
}

variable "ami_id" {
  description = "AMI ID for EC2 instances." # Use an ECS-optimized AMI
  type        = string
}