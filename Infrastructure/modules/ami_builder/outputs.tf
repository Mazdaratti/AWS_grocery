output "ami_id" {
  description = "The ID of the created AMI."
  value       = aws_ami_from_instance.grocery_ami.id
}