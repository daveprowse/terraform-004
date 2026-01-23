
terraform {
  backend "s3" {
    # Enter the bucket name you chose previously as well as a bucket key.
    bucket = ""
    key    = ""
    region = "us-east-2"
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  required_version = ">= 1.14.0"
}
