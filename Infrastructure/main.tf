provider "aws" {
  region = "eu-central-1"
  profile = "default"
}

# ECR Repositories
resource "aws_ecr_repository" "repos" {
  for_each = toset(["frontend", "backend"])
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
  source                     = "./modules/iam_role"
  iam_role_name              = "EC2Role"
  iam_instance_profile_name  = "EC2Profile"
}

module "ami_builder" {
  source = "./modules/ami_builder"

  base_ami_id               = "ami-06ee6255945a96aba" # Amazon Linux 2023 AMI
  instance_type             = "t2.micro"
  key_name                  = var.key_name
  subnet_id                 = module.vpc.public_subnet_ids[0]
  security_group_id         = module.security_groups.ec2_security_group_id
  iam_instance_profile_name = module.iam_role.iam_instance_profile_name
  private_key_path          = var.private_key_path
  region                    = "eu-central-1"
  ecr_registry_url          = local.ecr_registry_url
  frontend_image            = aws_ecr_repository.repos["frontend"].repository_url
  backend_image             = aws_ecr_repository.repos["backend"].repository_url
}

module "ec2_launch_template" {
  source                    = "./modules/ec2_launch_template"
  launch_template_name      = "grocery-launch-template"
  ami_id                    = module.ami_builder.ami_id
  instance_type             = "t2.micro"
  iam_instance_profile_name = module.iam_role.iam_instance_profile_name
  security_group_id         = module.security_groups.ec2_security_group_id
  volume_size               = 20
  volume_type               = "gp3"
}

module "asg" {
  source             = "./modules/asg"
  asg_name           = "grocery-asg"
  desired_capacity   = 1 # adjust for desired capacity
  max_size           = 4 # adjust for desired max_size
  min_size           = 0 # adjust for desired min_size
  public_subnet_ids  = module.vpc.public_subnet_ids
  launch_template_id = module.ec2_launch_template.launch_template_id
  ec2_name           = "grocery-ec2"
  target_group_arn   = module.alb.target_group_arn
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

# DB RDS Instance
resource "aws_db_instance" "grocery-db" {
  identifier             = "grocery-db"
  snapshot_identifier    = var.snapshot_id # Set the value of your snapshot ID in terraform.tfvars
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


