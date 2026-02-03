terraform {
  required_version = "~> 1.14.2"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.28.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Generate SSH key pair (ED25519)
resource "tls_private_key" "ssh_key" {
  algorithm = "ED25519"
}

# Save private key locally
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_openssh
  filename        = "${path.module}/lab-x-key.pem"
  file_permission = "0600"
}

# Create AWS key pair
resource "aws_key_pair" "lab_key" {
  key_name   = "${var.lab_name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# Security group for both instances
resource "aws_security_group" "lab_sg" {
  name        = "${var.lab_name}-sg"
  description = "Security group for Lab-X instances"

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "${var.lab_name}-sg"
    Student = var.student_name
  }
}

# EC2 instance for ZORK game
resource "aws_instance" "zork_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.lab_key.key_name
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  user_data = file("${path.module}/user-data-zork.sh")

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.lab_name}-zork"
    Student = var.student_name
  }
}

# EC2 instance for documentation
resource "aws_instance" "docs_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = aws_key_pair.lab_key.key_name
  vpc_security_group_ids = [aws_security_group.lab_sg.id]

  user_data = file("${path.module}/user-data-docs.sh")

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
  }

  tags = {
    Name    = "${var.lab_name}-docs"
    Student = var.student_name
  }
}

# Elastic IP for ZORK server
resource "aws_eip" "zork_eip" {
  domain = "vpc"

  tags = {
    Name    = "${var.lab_name}-zork-eip"
    Student = var.student_name
  }
}

# Associate EIP to ZORK server
resource "aws_eip_association" "zork_eip_assoc" {
  instance_id   = aws_instance.zork_server.id
  allocation_id = aws_eip.zork_eip.id
}

# Elastic IP for docs server
resource "aws_eip" "docs_eip" {
  domain = "vpc"

  tags = {
    Name    = "${var.lab_name}-docs-eip"
    Student = var.student_name
  }
}

# Associate EIP to docs server
resource "aws_eip_association" "docs_eip_assoc" {
  instance_id   = aws_instance.docs_server.id
  allocation_id = aws_eip.docs_eip.id
}
