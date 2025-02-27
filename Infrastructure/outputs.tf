output "ecr_repository_url_frontend" {
  value = aws_ecr_repository.repos["frontend"].repository_url
}

output "ecr_repository_url_backend" {
  value = aws_ecr_repository.repos["backend"].repository_url
}

output "ecr_repository_url_app" {
  value = aws_ecr_repository.repos["app"].repository_url
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

output "ec2_iam_role_name" {
  value       = module.iam_role.ec2_iam_role_name
  description = "The name of the IAM role."
}

output "iam_instance_profile_name" {
  value       = module.iam_role.iam_instance_profile_name
  description = "The name of the IAM instance profile."
}

output "ec2_iam_role_arn" {
  value       = module.iam_role.ec2_iam_role_name
  description = "The ARN of the IAM role."
}

output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "DNS name of the ALB"
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = module.ecs.cluster_name
}

output "cluster_id" {
  description = "The ID of the ECS Cluster"
  value       = module.ecs.cluster_id
}

output "task_definition_arn" {
  description = "The ARN of the ECS Task Definition"
  value       = module.ecs.task_definition_arn
}

output "ecs_service_name" {
  description = "The name of the ECS service."
  value       = module.ecs.service_name
}

output "ecs_service_id" {
  description = "The ARN of the ECS service."
  value       = module.ecs.service_id
}

output "ecs_task_execution_role_name" {
  value       = module.ecs.ecs_task_execution_role_name
  description = "The name of the IAM role."
}

output "ecs_task_execution_role_arn" {
  value       = module.ecs.ecs_task_execution_role_arn
  description = "The ARN of the IAM role."
}

output "ecs_launch_template_name" {
  value       = module.ecs.ecs_launch_template_name
  description = "The name of the EC2 launch template."
}

output "ecs_launch_template_id" {
  value       = module.ecs.ecs_launch_template_id
  description = "The ID of the EC2 launch template."
}

output "asg_name" {
  value       = module.ecs.asg_name
  description = "Name of the Auto Scaling Group"
}

output "asg_id" {
  value       = module.ecs.asg_id
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

output "db_instance_endpoint" {
  value = module.rds.rds_endpoint
  description = "The endpoint of the RDS instance."
}

output "rds_id" {
  value       = module.rds.rds_id
  description = "The ID of the RDS instance."
}

output "s3_bucket_name" {
  value = module.s3_bucket.s3_bucket_name
  description = "The name of the S3 bucket for avatars."
}

output "s3_bucket_id" {
  value       = module.s3_bucket.s3_bucket_id
  description = "ID of the created S3 bucket"
}

output "s3_bucket_arn" {
  description = "ARN of the created S3 bucket"
  value       = module.s3_bucket.s3_bucket_arn
}