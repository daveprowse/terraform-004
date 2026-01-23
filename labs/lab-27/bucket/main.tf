terraform {  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }
  required_version = ">= 1.14.0"
}

provider "aws" {
  region = "us-east-2"
}

module "s3_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "4.2.2"
  
  # Pick a name for your bucket and type it in the double-quotes. Add this to instances/version.tf as well
  bucket = ""
  
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "BucketOwnerEnforced"

  versioning = {
    enabled = true
  }
}
