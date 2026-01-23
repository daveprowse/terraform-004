output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "instance_state" {
  description = "Current state of the EC2 instance"
  value       = aws_instance.web_server.instance_state
}

output "elastic_ip" {
  description = "Elastic IP address (static)"
  value       = aws_eip.web_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the instance"
  value       = aws_instance.web_server.private_ip
}

output "web_url" {
  description = "URL to access the web server"
  value       = var.instance_state == "running" ? "http://${aws_eip.web_server.public_ip}" : "Instance is stopped"
}

output "iam_user_names" {
  description = "Names of created IAM users"
  value       = [for user in aws_iam_user.app_users : user.name]
}

output "iam_user_arns" {
  description = "ARNs of created IAM users"
  value       = [for user in aws_iam_user.app_users : user.arn]
}

output "s3_bucket_name" {
  description = "Name of the S3 logs bucket"
  value       = aws_s3_bucket.logs.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_server.id
}

output "cloudwatch_alarm_arn" {
  description = "ARN of CloudWatch CPU alarm"
  value       = var.enable_monitoring ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : "Monitoring disabled"
}
