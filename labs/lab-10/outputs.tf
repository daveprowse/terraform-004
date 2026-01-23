output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.test_instance.id
}

output "instance_state" {
  description = "State of the EC2 instance"
  value       = aws_instance.test_instance.instance_state
}

output "iam_user_names" {
  description = "Names of created IAM users"
  value       = aws_iam_user.users[*].name
}

output "iam_user_arns" {
  description = "ARNs of created IAM users"
  value       = aws_iam_user.users[*].arn
}
