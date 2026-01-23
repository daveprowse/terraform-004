################
## TEST FILE ###
################

# This works well for planning/testing, but applies are time consuming. 
# If you want to test with apply, use the test-users directory. That works with IAM users which apply almost instantaneously.
  
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

resource "aws_instance" "test_instance" {
  ami           = "ami-051f10b921a0c0595"
  instance_type = "t2.micro"
  tags = {
    Name = "TEST INSTANCE! DESTROY ME WHEN DONE!!"
  }
}
