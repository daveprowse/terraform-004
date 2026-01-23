## Refactoring Terraform State Lab
## This lab demonstrates how to rename resources without destroying them

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }

  required_version = ">= 1.14.2"
}

provider "aws" {
  region = "us-east-2"
}

## Step 1: Create initial resources with these names
resource "aws_iam_user" "dev_user_1" {
  name = "developer-alice"
  
  tags = {
    team = "Engineering"
  }
}

resource "aws_iam_user" "dev_user_2" {
  name = "developer-bob"
  
  tags = {
    team = "Engineering"
  }
}

## Step 2: After initial apply, you will rename these resources and use the moved block
## (Instructions in the lab document)
