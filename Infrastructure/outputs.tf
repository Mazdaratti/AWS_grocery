output "vpc_id" {
  value = aws_vpc.main.id
  description = "The ID of the VPC."
}

output "public_subnet_ids" {
  value = [aws_subnet.public_1.id, aws_subnet.public_2.id, aws_subnet.public_3.id]
  description = "The IDs of the public subnets."
}

output "private_subnet_ids" {
  value = [aws_subnet.private_1.id, aws_subnet.private_2.id, aws_subnet.private_3.id]
  description = "The IDs of the private subnets."
}

output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
  description = "The ID of the Internet Gateway."
}

output "alb_security_group_id" {
  value = aws_security_group.alb_sg.id
  description = "The ID of the ALB security group."
}

output "ec2_security_group_id" {
  value = aws_security_group.ec2_sg.id
  description = "The ID of the EC2 security group."
}

output "rds_security_group_id" {
  value = aws_security_group.rds_sg.id
  description = "The ID of the RDS security group."
}

output "ec2_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
  description = "The name of the IAM instance profile."
}

output "rds_instance_endpoint" {
  value = aws_db_instance.grocery-db.endpoint
  description = "The endpoint of the RDS instance."
}

output "s3_bucket_name" {
  value = aws_s3_bucket.grocery_s3.bucket
  description = "The name of the S3 bucket for avatars."
}