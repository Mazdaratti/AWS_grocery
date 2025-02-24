# EC2 Instance for AMI Creation
resource "aws_instance" "ami_builder" {
  ami           = var.base_ami_id
  instance_type = var.instance_type
  key_name      = var.key_name
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile = var.iam_instance_profile_name

  tags = {
    Name = "AMI-Builder"
  }

  # Ensure the AMI is created before the instance is destroyed
  lifecycle {
    create_before_destroy = true
  }
}

#Setup Instance
resource "null_resource" "setup_instance" {
  depends_on = [aws_instance.ami_builder]

  connection {
    type        = "ssh"
    host        = aws_instance.ami_builder.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
  source      = "${path.module}/install-docker-compose.sh"
  destination = "/tmp/install-docker-compose.sh"
}

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install-docker-compose.sh",
      "/tmp/install-docker-compose.sh"
    ]
  }
}

resource "null_resource" "wait_for_reboot" {
  depends_on = [null_resource.setup_instance]

  provisioner "local-exec" {
    command = "Write-Output 'Waiting for instance to reboot...'; Start-Sleep -Seconds 60"
    interpreter = ["PowerShell", "-Command"]
  }
}

# Provision the EC2 Instance
resource "null_resource" "configure_instance" {
  depends_on = [null_resource.wait_for_reboot]

  connection {
    type        = "ssh"
    host        = aws_instance.ami_builder.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content = templatefile("${path.module}/docker-compose.yml.tpl", {
      frontend_image = var.frontend_image
      backend_image  = var.backend_image
    })
    destination = "/home/ec2-user/docker-compose.yml"
  }

  # Generate the startup.sh script from the template
  provisioner "file" {
    content = templatefile("${path.module}/startup.sh.tpl", {
      region           = var.region
      ecr_registry_url = var.ecr_registry_url
    })
    destination = "/home/ec2-user/startup.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/startup.sh",
      "sudo yum install cronie -y",
      "sudo systemctl enable crond",
      "sudo systemctl start crond",
      "echo '@reboot /bin/bash /home/ec2-user/startup.sh >> /home/ec2-user/cron.log 2>&1' | crontab -"
    ]
  }
}

# Create AMI from the EC2 Instance
resource "aws_ami_from_instance" "grocery_ami" {
  name               = "grocery-ami-v3"
  source_instance_id = aws_instance.ami_builder.id
  description = "Based on ami-06ee6255945a96aba/docker/docker_compose/docker-compose.yml, getting images from ecr, automated start with cron, created with terraform"
  depends_on = [null_resource.configure_instance]
}

# Destroy the ami_builder instance after AMI creation
#resource "null_resource" "destroy_ami_builder" {
#  depends_on = [aws_ami_from_instance.grocery_ami]

#  provisioner "local-exec" {
#    command = "echo AMI created. Destroying ami_builder instance... && terraform destroy -target=aws_instance.ami_builder --auto-approve"
#  }
#}