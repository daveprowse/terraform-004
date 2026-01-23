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

resource "aws_instance" "computer_1" {
  ami           = "ami-051f10b921a0c0595"
  instance_type = "t2.micro"
}

resource "aws_iam_user" "accounts_3" {
  for_each = toset(["Indigo", "Violet"])
  name = each.key

  # Add a depends_on meta-argument here and set the dependent resource as the instance.
  # This will force Terraform to wait until the instance is fully built before applying the users.
  


}



#----------------------------------#
# More information about for_each: https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on 
#----------------------------------#
