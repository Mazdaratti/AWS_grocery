provider "aws" {
  region = "eu-central-1"
  profile = "default"
}

# ECR Repositories
resource "aws_ecr_repository" "repos" {
  for_each = toset(["frontend", "backend", "app"])
  name     = "aws_grocery-${each.key}"
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr             = "10.0.0.0/16"
  vpc_name             = "grocery-vpc"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

module "security_groups" {
  source = "./modules/security_groups"

  vpc_id              = module.vpc.vpc_id
  allowed_ssh_ip      = var.allowed_ssh_ip # Set your local IP in terraform.tfvars
  alb_ingress_ports   = [80, 443]
  ec2_ingress_ports   = [5000, 22]
  rds_port            = 5432
}

module "iam_role" {
  source                       = "./modules/iam_role"
  ec2_iam_role_name            = "EC2Role"
  iam_instance_profile_name    = "EC2Profile"
}

module "alb" {
  source                = "./modules/alb"
  alb_name              = "grocery-alb"
  alb_security_group_id = module.security_groups.alb_security_group_id
  public_subnet_ids     = module.vpc.public_subnet_ids
  target_group_name     = "grocery-alb-tg"
  target_group_port     = 5000
  vpc_id                = module.vpc.vpc_id
  health_check_path     = "/health"
}

module "ecs" {
  source = "./modules/ecs"

  cluster_name              = "grocery-ecs-cluster"
  task_family               = "grocery-task"
  container_name            = "grocery-app"
  container_image           = "${aws_ecr_repository.repos["app"].repository_url}:latest"
  container_port            = 5000
  desired_count             = 2
  target_group_arn          = module.alb.target_group_arn
  ecs_security_group_id     = module.security_groups.ec2_security_group_id
  subnet_ids                = module.vpc.public_subnet_ids
  instance_type             = "t2.micro"
  ami_id                    = "ami-0801a63f0471e5ad8" # ECS/Docker optimized Linux 2023
  iam_instance_profile_name = module.iam_role.iam_instance_profile_name
  key_name                  = var.key_name
}

# DB RDS Instance
module "rds" {
  source = "./modules/rds"
  identifier             = "grocery-db"
  snapshot_id            = var.snapshot_id # Set the value of your snapshot ID in terraform.tfvars
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "16.3"
  storage_encrypted      = true
  deletion_protection    = false
  publicly_accessible    = false
  multi_az               = true
  vpc_security_group_ids = [module.security_groups.rds_security_group_id]
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  skip_final_snapshot    = true
}

module "s3_bucket" {
  source                  = "./modules/s3_bucket"
  bucket_name             = var.bucket_name # Set your S3 bucket name in terraform.tfvars
  versioning_status       = "Disabled"
  lifecycle_status        = "Disabled"
  expiration_days         = 30
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
  prefix                  = "avatars/"
  avatar_filename         = "user_default.png"
  avatar_path             = "../backend/avatar/user_default.png"
}


