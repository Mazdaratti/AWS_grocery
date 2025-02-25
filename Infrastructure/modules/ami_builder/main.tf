# EC2 Instance for AMI Creation
resource "aws_instance" "ami_builder" {
  ami           = var.base_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile = var.iam_instance_profile_name

  user_data = templatefile("${path.module}/user_data.sh.tpl", {
    frontend_ecr_repository = var.frontend_image
    backend_ecr_repository  = var.backend_image
  })

  tags = {
    Name = "AMI-Builder"
  }

  # Ensure the AMI is created before the instance is destroyed
  lifecycle {
    create_before_destroy = true
  }
}

# Create AMI from the EC2 Instance
resource "aws_ami_from_instance" "grocery_ami" {
  name               = "grocery-ami-v3"
  source_instance_id = aws_instance.ami_builder.id
  description = "Based on ami-06ee6255945a96aba/docker/docker_compose/docker-compose.yml, getting images from ecr, automated start with cron, created with terraform"
  depends_on = [aws_instance.ami_builder]
}

# Destroy the ami_builder instance after AMI creation
#resource "null_resource" "destroy_ami_builder" {
#  depends_on = [aws_ami_from_instance.grocery_ami]

#  provisioner "local-exec" {
#    command = "echo AMI created. Destroying ami_builder instance... && terraform destroy -target=aws_instance.ami_builder --auto-approve"
#  }
#}