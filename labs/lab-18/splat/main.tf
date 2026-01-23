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

resource "aws_instance" "splat_lab" {
  ami           = "ami-051f10b921a0c0595"
  instance_type = "t2.micro"

  # Add your block devices here!
  
  tags = {
    Name = "Splat-Lab"
  }
}