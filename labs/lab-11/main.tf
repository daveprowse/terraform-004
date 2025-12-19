terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Optional: Configure credentials
  # access_key = var.aws_access_key
  # secret_key = var.aws_secret_key
}

# Data source for latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source to get availability zones in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Security Group
resource "aws_security_group" "test_sg" {
  name        = "${var.instance_name}-sg"
  description = "Security group for test instance"

  # Allow SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound
  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = "test"
  }
}

# EC2 Instance with Lifecycle Conditions
resource "aws_instance" "test_instance" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.test_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Test Instance - ${var.instance_name}</h1>" > /var/www/html/index.html
              EOF

  tags = {
    Name        = var.instance_name
    Environment = "test"
    ManagedBy   = "Terraform"
  }

  # LIFECYCLE CONDITIONS: All preconditions and postconditions in ONE block
  lifecycle {
    # PRECONDITION: Validate that we're deploying to the correct region
    precondition {
      condition     = var.aws_region == "us-east-2"
      error_message = "Instance must be created in us-east-2 region. Current region: ${var.aws_region}"
    }

    # POSTCONDITION: Verify that instance has a public DNS name
    postcondition {
      condition     = self.public_dns != ""
      error_message = "Instance must have a public DNS name. Instance ${self.id} does not have a public DNS assigned."
    }

    # POSTCONDITION: Verify instance is in a running state after creation
    postcondition {
      condition     = self.instance_state == "running"
      error_message = "Instance must be in running state. Current state: ${self.instance_state}"
    }

    # POSTCONDITION: Verify instance has expected instance type
    postcondition {
      condition     = self.instance_type == var.instance_type
      error_message = "Instance type mismatch. Expected: ${var.instance_type}, Got: ${self.instance_type}"
    }
  }
}
