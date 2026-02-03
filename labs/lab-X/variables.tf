variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
  default     = "us-east-2"
}

variable "student_name" {
  description = "Student name for resource tagging"
  type        = string
}

variable "lab_name" {
  description = "Name for the lab resources"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Ubuntu AMI ID (22.04 LTS for us-east-2)"
  type        = string
  default     = "ami-0ea3c35c5c3284d82"
}

# Note: Ubuntu 22.04 works fine, but consider newer AMIs!
