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

resource "aws_iam_user" "test_user" {
  name = "user-${count.index}" 
  count = 3
  tags = {
    time_created = timestamp()    
    department = "OPS"
  }
}