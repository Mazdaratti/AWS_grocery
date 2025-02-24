locals {
  ecr_registry_url = regex("^[^/]+", aws_ecr_repository.repos["frontend"].repository_url)
}