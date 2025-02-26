output "ecr_repository_url_frontend" {
  value = aws_ecr_repository.repos["frontend"]
}

output "ecr_repository_url_backend" {
  value = aws_ecr_repository.repos["backend"]
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}

output "db_subnet_group_name" {
  value = module.vpc.db_subnet_group_name
}

output "alb_security_group_id" {
  value = module.security_groups.alb_security_group_id
  description = "The ID of the ALB security group."
}

output "ec2_security_group_id" {
  value = module.security_groups.ec2_security_group_id
  description = "The ID of the EC2 security group."
}

output "rds_security_group_id" {
  value = module.security_groups.rds_security_group_id
  description = "The ID of the RDS security group."
}

output "iam_role_name" {
  value       = module.iam_role.iam_role_name
  description = "The name of the IAM role."
}

output "iam_instance_profile_name" {
  value       = module.iam_role.iam_instance_profile_name
  description = "The name of the IAM instance profile."
}

output "iam_role_arn" {
  value       = module.iam_role.iam_role_arn
  description = "The ARN of the IAM role."
}

output "launch_template_id" {
  value       = module.ec2_launch_template.launch_template_id
  description = "The ID of the EC2 launch template."
}

output "launch_template_name" {
  value       = module.ec2_launch_template.launch_template_name
  description = "The name of the EC2 launch template."
}

output "asg_id" {
  value       = module.asg.asg_id
  description = "ID of the Auto Scaling Group"
}

output "alb_arn" {
  value       = module.alb.alb_arn
  description = "ARN of the ALB"
}

output "target_group_arn" {
  value       = module.alb.target_group_arn
  description = "ARN of the Target Group"
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the ALB"
}

output "db_instance_endpoint" {
  value = aws_db_instance.grocery-db.endpoint
  description = "The endpoint of the RDS instance."
}

output "rds_id" {
  description = "The ID of the RDS DB instance"
  value       = aws_db_instance.grocery-db.id
}

output "s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_name
  description = "The name of the S3 bucket for avatars."
}

output "s3_bucket_id" {
  description = "ID of the created S3 bucket"
  value       = module.s3_bucket.s3_bucket_id
}

output "s3_bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}