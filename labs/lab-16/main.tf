## PUT TERRAFORM CLOUD BLOCK HERE!  ##

terraform {
  
  
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }



}


# Variable blocks directly within the main.tf. No arguments necessary.
variable "aws_access_key" {}
variable "aws_secret_key" {}

# provider arguments call on the variables which then call on terraform.tfvars for the values.
provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = "us-east-2"
}

# Add .gitignore file in this directory with the terraform.tfvars

resource "aws_instance" "tc_instance" {
  ami           = "ami-051f10b921a0c0595"
  instance_type = "t2.micro"

  tags = {
    Name = "TC-triggered-instance"
  }
}