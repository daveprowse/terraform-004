required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 6.28.0"
  }
}

# Provider configuration - uses credentials from deployment inputs
provider "aws" "configurations" {
  config {
    region     = var.aws_region
    access_key = var.aws_access_key  # From deployment's store block
    secret_key = var.aws_secret_key  # From deployment's store block
  }
}

variable "aws_region" {
  type    = string
  default = "us-east-2"
}

# AWS credentials passed from deployments via store block
variable "aws_access_key" {
  type      = string
  sensitive = true   # Required because variable set marks it as sensitive
  ephemeral = true   # Not persisted in state for security
}

variable "aws_secret_key" {
  type      = string
  sensitive = true   # Marked as sensitive - hidden in logs/UI
  ephemeral = true   # Not persisted in state for security
}

variable "user_names" {
  type = list(string)
}

variable "environment" {
  type = string
}

component "iam_users" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-user"
  version = "6.3.0"

  for_each = toset(var.user_names)

  providers = {
    aws = provider.aws.configurations
  }

  inputs = {
    name          = "${var.environment}-${each.value}"
    force_destroy = true
    
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform-Stacks"
    }
  }
}

output "user_arns" {
  type  = map(string)
  value = { for k, v in component.iam_users : k => v.arn }
}
