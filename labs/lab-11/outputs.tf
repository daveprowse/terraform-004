output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.test_instance.id
}

output "instance_public_ip" {
  description = "Public IP address of the instance"
  value       = aws_instance.test_instance.public_ip
}

output "instance_public_dns" {
  description = "Public DNS name of the instance"
  value       = aws_instance.test_instance.public_dns
}

output "instance_state" {
  description = "State of the instance"
  value       = aws_instance.test_instance.instance_state
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.test_sg.id
}

output "web_url" {
  description = "URL to access the test web server"
  value       = "http://${aws_instance.test_instance.public_dns}"
}

output "test_summary" {
  description = "Summary of test validations"
  value       = <<-EOT
    
    ========================================
    Terraform Testing Demo - Summary
    ========================================
    
    Instance Information:
    - ID: ${aws_instance.test_instance.id}
    - Type: ${aws_instance.test_instance.instance_type}
    - State: ${aws_instance.test_instance.instance_state}
    - Public IP: ${aws_instance.test_instance.public_ip}
    - Public DNS: ${aws_instance.test_instance.public_dns}
    - Region: ${var.aws_region}
    
    Tests Passed:
    ✓ Precondition: Region is us-east-2
    ✓ Postcondition: Instance has public DNS
    ✓ Postcondition: Instance is running
    ✓ Postcondition: Instance type matches expected
    
    Web Server:
    - URL: http://${aws_instance.test_instance.public_dns}
    
    Run checks: terraform plan -refresh-only
    
  EOT
}
