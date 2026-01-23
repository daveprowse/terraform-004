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
  region = var.region
}

resource "aws_instance" "workspace_testing" {
  ami           = "ami-051f10b921a0c0595"
  instance_type = var.instance_type

  tags = {
    Name = var.name
  }
}