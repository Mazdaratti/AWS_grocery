provider "aws" {
  region = var.region
  profile = "default"
}

# ECR Repositories
resource "aws_ecr_repository" "frontend" {
  name = "aws_grocery-frontend"  # Replace with your actual frontend repo name
}

resource "aws_ecr_repository" "backend" {
  name = "aws_grocery-backend"  # Replace with your actual backend repo name
}

# VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "grocery-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# Public Subnets
resource "aws_subnet" "public_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_blocks[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_blocks[1]
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-2" }
}

resource "aws_subnet" "public_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.public_subnet_cidr_blocks[2]
  availability_zone = data.aws_availability_zones.available.names[2]
  map_public_ip_on_launch = true
  tags = { Name = "public-subnet-3" }
}

# Private Subnets (For RDS Only)
resource "aws_subnet" "private_1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_blocks[0]
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = { Name = "private-subnet-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_blocks[1]
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = { Name = "private-subnet-2" }
}

resource "aws_subnet" "private_3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr_blocks[2]
  availability_zone = data.aws_availability_zones.available.names[2]
  tags = { Name = "private-subnet-3" }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "grocery-igw"
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_1" {
  subnet_id = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_3" {
  subnet_id = aws_subnet.public_3.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_db_subnet_group" "main" {
  name        = "grocery-db-subnet-group"
  subnet_ids  = [
    aws_subnet.private_1.id,
    aws_subnet.private_2.id,
    aws_subnet.private_3.id
  ]
  tags = {
    Name = "grocery-db-subnet-group"
  }
}

# Security Groups
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.main.id
  name   = "alb-sg"
  description = "Security group for Load Balancer"
  ingress {
    from_port   = var.alb_security_group_ingress_ports[0]
    to_port     = var.alb_security_group_ingress_ports[0]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = var.alb_security_group_ingress_ports[1]
    to_port     = var.alb_security_group_ingress_ports[1]
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ec2_sg" {
  vpc_id = aws_vpc.main.id
  name   = "ec2-sg"
  description = "Security group for EC2 instances"
  
  ingress {
    from_port   = var.ec2_security_group_ingress_ports[0]
    to_port     = var.ec2_security_group_ingress_ports[0]
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
    description = "Allow HTTP access from ALB to EC2"
  }
  ingress {
    from_port = var.ec2_security_group_ingress_ports[1]
    to_port   = var.ec2_security_group_ingress_ports[1]
    protocol  = "tcp"
    cidr_blocks = [var.allowed_ssh_ip]
    description = "Allow SSH access from specific IP"
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id
  name   = "rds-sg"
  description = "Security group for RDS instances"
  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  egress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
}

# IAM Role for EC2 (Access to ECR and S3)
resource "aws_iam_role" "ec2_role" {
  name = "EC2Role"

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

# Attach AmazonEC2ContainerRegistryPullOnly Policy
resource "aws_iam_role_policy_attachment" "ecr_pull" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly"
}

# Attach AmazonS3FullAccess Policy
resource "aws_iam_role_policy_attachment" "s3_full_access" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# IAM Instance Profile (Required for EC2 to Use the Role)
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "EC2Profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Launch Template
resource "aws_launch_template" "grocery" {
  name          = "grocery-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = true
    security_groups = [aws_security_group.ec2_sg.id]
  }
  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = 20
      volume_type = "gp3"
      delete_on_termination = true
    }
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "grocery_asg" {
  name                 = "grocery-asg"
  desired_capacity     = 0
  max_size            = 2
  min_size            = 0
  vpc_zone_identifier = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id]
  launch_template {
    id      = aws_launch_template.grocery.id
    version = "$Latest"
  }

tag {
    key                 = "Name"
    value               = "grocery-ec2"
    propagate_at_launch = true
  }
}


# ALB (Application Load Balancer)
resource "aws_lb" "grocery_alb" {
  name               = "grocery-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id]

  enable_deletion_protection = false
}

# Target Group for ALB
resource "aws_lb_target_group" "grocery_alb_tg" {
  name     = "grocery-alb-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
  target_type = "instance"

  health_check {
    path                = "/health"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# ALB Listener
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.grocery_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.grocery_alb_tg.arn
  }
}

# Attach ASG to Target Group
resource "aws_autoscaling_attachment" "asg_attachment" {
  autoscaling_group_name = aws_autoscaling_group.grocery_asg.id
  lb_target_group_arn    = aws_lb_target_group.grocery_alb_tg.arn
}


# DB RDS Instance
resource "aws_db_instance" "grocery-db" {
  identifier          = "grocery-db"
  #snapshot_identifier = var.snapshot_id
  instance_class      = "db.t3.micro"
  allocated_storage   = 20
  storage_type        = "gp2"
  engine             = "postgres"
  engine_version     = "16.3"
  storage_encrypted = true
  deletion_protection = false
  publicly_accessible = false
  multi_az          = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  skip_final_snapshot  = true
}

# S3 Bucket
resource "aws_s3_bucket" "grocery_s3" {
  bucket = "andreys-grocery-s3"
}

#resource "aws_s3_bucket_versioning" "grocery_s3_versioning" {
  #bucket = aws_s3_bucket.grocery_s3.id
  #versioning_configuration {
    #status = "Enabled"
  #}
#}

#resource "aws_s3_bucket_lifecycle_configuration" "grocery_s3_lifecycle" {
  #bucket = aws_s3_bucket.grocery_s3.id

  #rule {
    #id     = "expire-old-avatars"
    #status = "Enabled"

    #filter {
      #prefix = "avatars/"
    #}

    #expiration {
      #days = 30  # Delete objects in the avatars/ folder after 30 days
    #}
  #}
#}

resource "aws_s3_bucket_public_access_block" "grocery_s3_block" {
  bucket = aws_s3_bucket.grocery_s3.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Creating an empty "avatars/" folder (simulated with an empty object)
#resource "aws_s3_object" "avatars_folder" {
  #bucket = aws_s3_bucket.grocery_s3.id
  #key    = "avatars/"
#}



resource "aws_s3_bucket_policy" "avatars_policy" {
  bucket = aws_s3_bucket.grocery_s3.id
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": "*",
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::andreys-grocery-s3/avatars/*"
    }
  ]
}
POLICY
  depends_on = [aws_s3_bucket_public_access_block.grocery_s3_block]
}

resource "aws_s3_bucket_cors_configuration" "avatars_cors" {
  bucket = aws_s3_bucket.grocery_s3.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "POST", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
}

resource "aws_s3_object" "avatar_image" {
  bucket = aws_s3_bucket.grocery_s3.id
  key    = "avatars/user_default.png"  # Path inside the bucket
  source = "../backend/avatar/user_default.png"  # Local file path
}

