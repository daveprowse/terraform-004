output "student_name" {
  description = "Student name"
  value       = var.student_name
}

output "lab_name" {
  description = "Lab resource name"
  value       = var.lab_name
}

output "zork_public_ip" {
  description = "Public IP address of ZORK server"
  value       = aws_eip.zork_eip.public_ip
}

output "zork_url" {
  description = "URL to access ZORK game"
  value       = "http://${aws_eip.zork_eip.public_ip}"
}

output "zork_ssh" {
  description = "SSH command for ZORK server"
  value       = "ssh -i lab-x-key.pem ubuntu@${aws_eip.zork_eip.public_ip}"
}

output "docs_public_ip" {
  description = "Public IP address of documentation server"
  value       = aws_eip.docs_eip.public_ip
}

output "docs_url" {
  description = "URL to access documentation"
  value       = "http://${aws_eip.docs_eip.public_ip}"
}

output "docs_ssh" {
  description = "SSH command for documentation server"
  value       = "ssh -i lab-x-key.pem ubuntu@${aws_eip.docs_eip.public_ip}"
}
