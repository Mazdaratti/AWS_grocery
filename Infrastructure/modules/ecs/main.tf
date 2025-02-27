# ECS Cluster
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = var.task_family
  network_mode             = "bridge"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = var.container_name
      image     = var.container_image
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
        }
      ]
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "service" {
  name            = "${var.task_family}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = var.desired_count
  launch_type     = "EC2"

  load_balancer {
    target_group_arn = var.target_group_arn
    container_name   = var.container_name
    container_port   = var.container_port
  }

  depends_on = [aws_ecs_cluster.cluster, aws_ecs_task_definition.task]
}

# IAM Role for ECS Tasks
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.task_family}-ecs-task-execution-role"

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

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Capacity Provider
resource "aws_ecs_capacity_provider" "capacity_provider" {
  name = "${var.task_family}-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.ecs_asg.arn
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = [aws_ecs_capacity_provider.capacity_provider.name]

  default_capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.capacity_provider.name
  }
}

# Auto Scaling Group for ECS
resource "aws_launch_template" "ecs_launch_template" {
  name_prefix   = "${var.task_family}-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  iam_instance_profile {
    name = var.iam_instance_profile_name
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.ecs_security_group_id]
  }

  user_data = base64encode(<<-EOF
              #!/bin/bash
              echo ECS_CLUSTER=${aws_ecs_cluster.cluster.name} >> /etc/ecs/ecs.config
              EOF
              )
}

resource "aws_autoscaling_group" "ecs_asg" {
  name_prefix          = "${var.task_family}-asg-"
  vpc_zone_identifier  = var.subnet_ids
  launch_template {
    id      = aws_launch_template.ecs_launch_template.id
    version = "$Latest"
  }
  min_size             = 1
  max_size             = 4
  desired_capacity     = var.desired_count

  tag {
    key                 = "Name"
    value               = "${var.task_family}-ecs-instance"
    propagate_at_launch = true
  }
}

# Attach ASG to Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.ecs_asg.id
  lb_target_group_arn    = var.target_group_arn
}