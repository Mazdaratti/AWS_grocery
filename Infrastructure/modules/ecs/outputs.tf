output "ecs_task_execution_role_name" {
  value       = aws_iam_role.ecs_task_execution_role.name
  description = "The name of the IAM role."
}

output "ecs_task_execution_role_arn" {
  value       = aws_iam_role.ecs_task_execution_role.arn
  description = "The ARN of the IAM role."
}

output "cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.cluster.name
}

output "cluster_id" {
  description = "The ID of the ECS Cluster"
  value       = aws_ecs_cluster.cluster.id
}

output "task_definition_arn" {
  description = "The ARN of the ECS Task Definition"
  value       = aws_ecs_task_definition.task.arn
}

output "service_name" {
  description = "Name of the ECS service"
  value       = aws_ecs_service.service.name
}

output "service_id" {
  description = "The ID of the ECS service"
  value       = aws_ecs_service.service.id
}

output "ecs_launch_template_name" {
  value       = aws_launch_template.ecs_launch_template.name
  description = "The name of the EC2 launch template."
}

output "ecs_launch_template_id" {
  value       = aws_launch_template.ecs_launch_template.id
  description = "The ID of the EC2 launch template."
}

output "asg_name" {
  value       = aws_autoscaling_group.ecs_asg.name
  description = "Name of the Auto Scaling Group"
}

output "asg_id" {
  value       = aws_autoscaling_group.ecs_asg.id
  description = "ID of the Auto Scaling Group"
}