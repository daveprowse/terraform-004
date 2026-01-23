variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_state" {
  description = "Desired state of the EC2 instance (running or stopped)"
  type        = string
  default     = "running"
  
  validation {
    condition     = contains(["running", "stopped"], var.instance_state)
    error_message = "Instance state must be 'running' or 'stopped'."
  }
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH (use for_each in security group)"
  type        = set(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_rules" {
  description = "Map of ingress rules (demonstrates dynamic blocks)"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = {
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH access"
    }
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    }
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    }
  }
}

variable "iam_users" {
  description = "Set of IAM usernames to create (demonstrates for_each)"
  type        = set(string)
  default     = ["app-deployer", "log-reader"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}
