# main.tf - Using HCP Vault with Terraform Cloud

terraform {
  cloud {
    organization = "prowse_tech"
    
    workspaces {
      name = "hcp-vault-demo"
    }
  }
  
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.5.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
  }
  
  required_version = "~>1.14.2"
}

# Variables for HCP Vault configuration
variable "vault_address" {
  description = "HCP Vault cluster public URL"
  type        = string
}

variable "vault_token" {
  description = "HCP Vault admin token"
  type        = string
  sensitive   = true
}

variable "vault_namespace" {
  description = "HCP Vault namespace"
  type        = string
  default     = "admin"
}

# Vault provider configuration for HCP Vault
provider "vault" {
  address   = var.vault_address
  token     = var.vault_token
  namespace = var.vault_namespace
}

# Read AWS credentials from HCP Vault
data "vault_kv_secret_v2" "aws_creds" {
  mount = "kv"
  name  = "aws"
}

# AWS provider using credentials from HCP Vault
provider "aws" {
  region     = "us-east-2"
  access_key = data.vault_kv_secret_v2.aws_creds.data["access_key"]
  secret_key = data.vault_kv_secret_v2.aws_creds.data["secret_key"]
}

# EC2 instance resource
resource "aws_instance" "hcp_vault_demo" {
  ami           = "ami-051f10b921a0c0595"  # Debian 13 us-east-2
  instance_type = "t2.micro"

  tags = {
    Name        = "HCP-Vault-TFC-Demo"
    Lab         = "HCP-Vault-Terraform-Cloud"
    Environment = "Demo"
  }
}

# Output instance information
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.hcp_vault_demo.id
}

output "instance_public_ip" {
  description = "EC2 instance public IP"
  value       = aws_instance.hcp_vault_demo.public_ip
}
