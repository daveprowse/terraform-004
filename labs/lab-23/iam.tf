# IAM Users with EXPLICIT DEPENDS_ON
# These users are created AFTER the EC2 instance
# Use case: Users need instance to exist before they can deploy to it

resource "aws_iam_user" "app_users" {
  for_each = var.iam_users
  
  name = "${var.environment}-${each.value}"
  path = "/app-users/"
  
  tags = {
    Name        = "${var.environment}-${each.value}"
    Environment = var.environment
    Purpose     = "Application deployment and monitoring"
  }
  
  # Explicit dependency: Create users only AFTER instance exists
  depends_on = [aws_instance.web_server]
}

# IAM Policy for S3 access
resource "aws_iam_policy" "s3_logs_access" {
  name        = "${var.environment}-s3-logs-access"
  description = "Allow read access to log bucket"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
      }
    ]
  })
}

# Attach policy to users using FOR_EACH
resource "aws_iam_user_policy_attachment" "s3_logs_access" {
  for_each = aws_iam_user.app_users
  
  user       = each.value.name
  policy_arn = aws_iam_policy.s3_logs_access.arn
}
