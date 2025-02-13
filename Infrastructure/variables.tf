variable "region" {
  description = "AWS region to deploy the resources."
  type        = string
  default     = "eu-central-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instances."
  type        = string
}

variable "snapshot_id" {
  description = "RDS snapshot ID to restore the database from."
  type        = string
}

variable "instance_type" {
  description = "Instance type for EC2."
  type        = string
  default     = "t2.micro"
}

variable "allowed_ssh_ip" {
  description = "The IP address that is allowed to SSH into the EC2 instances"
  type        = string
  default     = "0.0.0.0/0"                                            
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the VPC"
  default     = "10.0.0.0/16"  # Change this if needed
}

variable "public_subnet_cidr_blocks" {
  description = "CIDR blocks for public subnets."
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "private_subnet_cidr_blocks" {
  description = "CIDR blocks for private subnets."
  type        = list(string)
  default     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "alb_security_group_ingress_ports" {
  description = "Ports for the ALB security group ingress."
  type        = list(number)
  default     = [80, 443]
}

variable "ec2_security_group_ingress_ports" {
  description = "Ports for the EC2 security group ingress."
  type        = list(number)
  default     = [5000, 22]
}
