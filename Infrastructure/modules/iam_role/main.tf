# IAM Role for EC2 (Access to ECR and S3)
resource "aws_iam_role" "ec2_role" {
  name = var.ec2_iam_role_name

  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }
  EOF
}

# Attach AmazonEC2ContainerRegistryPullOnly Policy NOT NEEDED USING ECS Agent
#resource "aws_iam_role_policy_attachment" "ecr_pull" {
  #role       = aws_iam_role.ec2_role.name
  #policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
#}

# Attach AmazonS3FullAccess Policy
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# IAM Instance Profile (Required for EC2 to Use the Role)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = var.iam_instance_profile_name
  role = aws_iam_role.ec2_role.name
}

# IAM Role for ECS Tasks (Execution Role Only)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# Attach AmazonECSTaskExecutionRolePolicy to the ECS task execution role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Custom Policy for ECS Container Instances
resource "aws_iam_policy" "ecs_container_instance_policy" {
  name        = "ECSContainerInstancePolicy"
  description = "Policy to allow ECS container instance actions"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ecs:RegisterContainerInstance",
          "ecs:DeregisterContainerInstance",
          "ecs:UpdateContainerInstancesState",
          "ecs:SubmitTaskStateChange",
          "ecs:CreateCluster",
          "ecs:DiscoverPollEndpoint",
          "ecs:Poll",
          "ecs:StartTelemetrySession",
          "ecs:Submit*",
          "ecs:StartTask",
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach Custom ECS Container Instance Policy to EC2 Role
resource "aws_iam_role_policy_attachment" "ecs_container_instance_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ecs_container_instance_policy.arn
}