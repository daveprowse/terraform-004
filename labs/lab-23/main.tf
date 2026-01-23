terraform {
  required_version = ">= 1.14.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Lab         = "Lab-23-Advanced-AWS"
    }
  }
}

# Data source: Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
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

# Data source: Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group with DYNAMIC BLOCKS
resource "aws_security_group" "web_server" {
  name        = "${var.environment}-web-server-sg"
  description = "Security group for web server with dynamic ingress rules"
  vpc_id      = data.aws_vpc.default.id
  
  # Dynamic block creates ingress rules from variable
  dynamic "ingress" {
    for_each = var.ingress_rules
    
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name = "${var.environment}-web-server-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.web_server.id]
  
  monitoring = var.enable_monitoring
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from ${var.environment} environment!</h1>" > /var/www/html/index.html
              echo "<p>Instance ID: $(ec2-metadata --instance-id | cut -d ' ' -f 2)</p>" >> /var/www/html/index.html
              EOF
  
  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
  }
  
  lifecycle {
    ignore_changes = [user_data]
  }
}

# Instance State Management using AWS CLI
resource "null_resource" "instance_state_manager" {
  triggers = {
    instance_id    = aws_instance.web_server.id
    desired_state  = var.instance_state
  }

  provisioner "local-exec" {
    command = var.instance_state == "stopped" ? "aws ec2 stop-instances --instance-ids ${aws_instance.web_server.id} --region ${var.aws_region}" : "aws ec2 start-instances --instance-ids ${aws_instance.web_server.id} --region ${var.aws_region}"
  }
}

# ELASTIC IP - Static public address
resource "aws_eip" "web_server" {
  domain = "vpc"
  
  tags = {
    Name        = "${var.environment}-web-server-eip"
    Environment = var.environment
  }
}

# EIP Association
resource "aws_eip_association" "web_server" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.web_server.id
  
  # Only associate if instance is running
  count = var.instance_state == "running" ? 1 : 0
}
