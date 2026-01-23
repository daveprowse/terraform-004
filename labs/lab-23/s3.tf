# S3 Bucket for application logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-web-server-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "${var.environment}-logs"
    Environment = var.environment
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rule
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  rule {
    id     = "delete-old-logs"
    status = "Enabled"
    
    filter {
      prefix = ""
    }
    
    expiration {
      days = 90
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Data source for account ID
data "aws_caller_identity" "current" {}
