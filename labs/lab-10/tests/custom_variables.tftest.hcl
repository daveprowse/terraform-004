# Unit test: Validates custom instance configuration

variables {
  instance_type = "t3.small"
  instance_name = "custom-test-instance"
}

run "check_custom_instance_type" {
  command = plan

  assert {
    condition     = aws_instance.test_instance.instance_type == "t3.small"
    error_message = "Expected instance type t3.small, got ${aws_instance.test_instance.instance_type}"
  }
}

run "check_custom_instance_name" {
  command = plan

  assert {
    condition     = aws_instance.test_instance.tags["Name"] == "custom-test-instance"
    error_message = "Expected Name tag 'custom-test-instance', got ${aws_instance.test_instance.tags["Name"]}"
  }
}
