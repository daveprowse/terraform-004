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

resource "aws_instance" "count_lab" {
  # add your count meta-argument here!
  ami           = "ami-050352a65e954abb1"
  instance_type = "t2.micro"
    
  tags = {
    # Modify the Name tag so that it uses the count_index argument!
    Name = "Count-Lab"
  }
}