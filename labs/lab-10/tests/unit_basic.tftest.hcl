# Unit test: Validates resource counts and basic attributes

run "check_iam_user_count" {
  command = plan

  assert {
    condition     = length(aws_iam_user.users) == 3
    error_message = "Expected 3 IAM users, got ${length(aws_iam_user.users)}"
  }
}

run "check_instance_type" {
  command = plan

  assert {
    condition     = aws_instance.test_instance.instance_type == "t2.micro"
    error_message = "Expected instance type t2.micro, got ${aws_instance.test_instance.instance_type}"
  }
}

run "check_environment_tag" {
  command = plan

  assert {
    condition     = aws_instance.test_instance.tags["Environment"] == "test"
    error_message = "Expected Environment tag to be 'test'"
  }
}
