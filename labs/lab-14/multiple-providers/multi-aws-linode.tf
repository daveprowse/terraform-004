# Example of multiple providers: AWS and Linode
# This is non-functional code for analytical purposes only. 

## In the terraform block we specify the AWS and Linode sources
## for the provider plugins and the versions.
terraform {
  required_version = ">= 1.14.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
    linode = {
      source  = "linode/linode"
      version = "~> 3.6.0"
    }

  }
}

## In provider blocks we specify things like the AWS region
## and the token used to allow access to Linode
provider "aws" {
  region = "us-east-2"
}

provider "linode" {
  token = var.token  
}

## In another file we might specify a Linode instance in the following way:
resource "linode_instance" "lnsf_arch" {
  label           = "ARCH-SERVER"
  image           = "linode/arch"
  region          = "us-east"
  type            = "g6-standard-1"
  authorized_keys = var.key
  root_pass       = var.password
}
## NOTE: Secure credentials would best be stored in a different fashion!

variable "token" {}
variable "key" {}
variable "password" {}