variable "region" {
  description = "AWS region to deploy the resources."
  type        = string
  default     = "eu-central-1"
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "main-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "allowed_ssh_ip" {
  description = "The IP address that is allowed to SSH into the EC2 instances"
  type        = string
  default = "0.0.0.0/0" # Set your actual IP in terraform.tfvar
}

variable "alb_ingress_ports" {
  description = "Ports for the ALB security group ingress."
  type        = list(number)
  default     = [80, 443]
}

variable "ec2_ingress_ports" {
  description = "Ports for the EC2 security group ingress."
  type        = list(number)
  default     = [5000, 22]
}

variable "rds_port" {
  type    = number
  default = 5432
}

variable "ec2_iam_role_name" {
  description = "The name of the IAM role for EC2"
  type        = string
  default     = "EC2Role"
}

variable "iam_instance_profile_name" {
  description = "The name of the IAM instance profile"
  type        = string
  default     = "ec2-profile"
}

variable "instance_type" {
  description = "Instance type for EC2."
  type        = string
  default     = "t2.micro"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances." # Use an ECS-optimized AMI
  type        = string
  default     = "ami-06ee6255945a96aba"
}

variable "alb_name" {
  description = "Name of the Application Load Balancer"
  type        = string
  default     = "alb"
}

variable "target_group_name" {
  description = "Name of the Target Group"
  type        = string
  default     = "alb-tg"
}

variable "target_group_port" {
  description = "Port for the Target Group"
  type        = number
  default     = 5000
}

variable "health_check_path" {
  description = "Health check path for the target group"
  type        = string
  default     = "/health"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
}

variable "snapshot_id" {
  description = "RDS snapshot ID to restore the database from."
  type        = string
}

variable "bucket_name" {
  description = "The name of the S3 bucket"
  type        = string
  default     = "aws-grocery-s3" # Be sure to set unique name!!!
}

variable "versioning_status" {
  description = "The versioning status of the S3 bucket"
  type        = string
  default     = "Disabled"
}

variable "lifecycle_status" {
  description = "Lifecycle policy status"
  type        = string
  default     = "Disabled"
}

variable "expiration_days" {
  description = "The number of days to wait before deleting objects"
  type        = number
  default     = 30
}

variable "block_public_acls" {
  description = "Whether to block public ACLs"
  type        = bool
  default     = false
}

variable "block_public_policy" {
  description = "Whether to block public policy"
  type        = bool
  default     = false
}

variable "ignore_public_acls" {
  description = "Whether to ignore public ACLs"
  type        = bool
  default     = false
}

variable "restrict_public_buckets" {
  description = "Whether to restrict public buckets"
  type        = bool
  default     = false
}
variable "prefix" {
  description = "The prefix for the avatars storage path"
  type        = string
  default     = "avatars/"
}

variable "avatar_filename" {
  description = "The default avatar filename"
  type        = string
  default     = "user_default.png"
}

variable "avatar_path" {
  description = "Path to the local default avatar image file"
  type        = string
  default     = "../backend/avatar/user_default.png"
}