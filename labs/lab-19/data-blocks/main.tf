## This lab is already complete. You don't need to do anything other than `terraform init` and `terraform apply`.
## Review the data source block code and how it is called from the resource block.

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

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "data_block_instance" {
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
}

### NOTES
## You will note that the instance doesn't have a name. Feel free to add one with tags!

## The data block uses "owners". You can find out the owner ID of AMIs by going to the AWS console,
## choose AMIs, and in the filter, select Public Images. Click the Search and granulate as necessary. 
## Or, you can use the following command for the particular owner we just used:
# aws ec2 describe-images --owners 099720109477 --region us-east-2 \
#   --filters "Name=name,Values=ubuntu/images/*" \
#   --query 'sort_by(Images, &CreationDate)[-1].[ImageId,Name,CreationDate]' --output table

## Ownership IDs will be different for the AWS GovCloud and for China.
## More information on data sources: https://developer.hashicorp.com/terraform/language/data-sources 
## More information on data source: aws_ami: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami
