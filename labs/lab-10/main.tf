terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# EC2 Instance
resource "aws_instance" "test_instance" {
  ami           = var.ami_id
  instance_type = var.instance_type

  tags = {
    Name        = var.instance_name
    Environment = "test"
  }
}

# IAM Users
resource "aws_iam_user" "users" {
  count = length(var.iam_usernames)
  name  = var.iam_usernames[count.index]

  tags = {
    Environment = "test"
  }
}
