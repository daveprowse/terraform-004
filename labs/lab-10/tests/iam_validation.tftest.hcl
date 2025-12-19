# Unit test: Validates IAM user names and attributes

variables {
  iam_usernames = ["test-user-1", "test-user-2", "test-user-3"]
}

run "check_user_1_exists" {
  command = plan

  assert {
    condition     = contains(aws_iam_user.users[*].name, "test-user-1")
    error_message = "IAM user test-user-1 not found"
  }
}

run "check_user_2_exists" {
  command = plan

  assert {
    condition     = contains(aws_iam_user.users[*].name, "test-user-2")
    error_message = "IAM user test-user-2 not found"
  }
}

run "check_user_3_exists" {
  command = plan

  assert {
    condition     = contains(aws_iam_user.users[*].name, "test-user-3")
    error_message = "IAM user test-user-3 not found"
  }
}

run "check_all_users_tagged" {
  command = plan

  assert {
    condition     = alltrue([for user in aws_iam_user.users : user.tags["Environment"] == "test"])
    error_message = "Not all IAM users have Environment tag set to 'test'"
  }
}
