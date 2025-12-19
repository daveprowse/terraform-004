variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
  default     = "ami-00e428798e77d38d9"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "instance_name" {
  description = "Name tag for EC2 instance"
  type        = string
  default     = "test-instance"
}

variable "iam_usernames" {
  description = "List of IAM usernames"
  type        = list(string)
  default     = ["test-user-1", "test-user-2", "test-user-3"]
}
