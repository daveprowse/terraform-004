# Check Blocks for Instance Health and Configuration Validation
# These run continuously and can be checked with: terraform plan -refresh-only

# Check 1: Verify instance is accessible and healthy
check "instance_health" {
  data "aws_instance" "verify" {
    instance_id = aws_instance.test_instance.id
  }

  assert {
    condition     = data.aws_instance.verify.instance_state == "running"
    error_message = "Instance ${aws_instance.test_instance.id} is not in running state. Current state: ${data.aws_instance.verify.instance_state}"
  }

  assert {
    condition     = data.aws_instance.verify.public_ip != ""
    error_message = "Instance ${aws_instance.test_instance.id} does not have a public IP address."
  }

  assert {
    condition     = data.aws_instance.verify.public_dns != ""
    error_message = "Instance ${aws_instance.test_instance.id} does not have a public DNS name."
  }
}

# Check 2: Verify instance configuration matches expected values
check "instance_configuration" {
  data "aws_instance" "config_check" {
    instance_id = aws_instance.test_instance.id
  }

  assert {
    condition     = data.aws_instance.config_check.instance_type == var.instance_type
    error_message = "Instance type mismatch. Expected: ${var.instance_type}, Got: ${data.aws_instance.config_check.instance_type}"
  }

  assert {
    condition     = data.aws_instance.config_check.ami == data.aws_ami.amazon_linux.id
    error_message = "AMI mismatch. Expected: ${data.aws_ami.amazon_linux.id}, Got: ${data.aws_instance.config_check.ami}"
  }

  assert {
    condition     = length(data.aws_instance.config_check.vpc_security_group_ids) > 0
    error_message = "Instance ${aws_instance.test_instance.id} does not have any security groups attached."
  }
}

# Check 3: Verify security group configuration
check "security_group_configuration" {
  data "aws_security_group" "verify_sg" {
    id = aws_security_group.test_sg.id
  }

  assert {
    condition     = data.aws_security_group.verify_sg.id != ""
    error_message = "Security group must exist and have a valid ID."
  }

  assert {
    condition     = data.aws_security_group.verify_sg.name == "${var.instance_name}-sg"
    error_message = "Security group name mismatch. Expected: ${var.instance_name}-sg, Got: ${data.aws_security_group.verify_sg.name}"
  }

  assert {
    condition     = data.aws_security_group.verify_sg.description != ""
    error_message = "Security group must have a description."
  }
}

# Check 4: Verify instance is in correct region
check "instance_region" {
  data "aws_instance" "region_check" {
    instance_id = aws_instance.test_instance.id
  }

  assert {
    condition     = can(regex("^us-east-2", data.aws_instance.region_check.availability_zone))
    error_message = "Instance must be in us-east-2 region. Availability zone: ${data.aws_instance.region_check.availability_zone}"
  }
}

# Check 5: Verify instance tags are properly set
check "instance_tags" {
  data "aws_instance" "tag_check" {
    instance_id = aws_instance.test_instance.id
  }

  assert {
    condition     = data.aws_instance.tag_check.tags["Environment"] == "test"
    error_message = "Instance must have Environment tag set to 'test'. Current value: ${try(data.aws_instance.tag_check.tags["Environment"], "not set")}"
  }

  assert {
    condition     = data.aws_instance.tag_check.tags["ManagedBy"] == "Terraform"
    error_message = "Instance must have ManagedBy tag set to 'Terraform'. Current value: ${try(data.aws_instance.tag_check.tags["ManagedBy"], "not set")}"
  }

  assert {
    condition     = data.aws_instance.tag_check.tags["Name"] != ""
    error_message = "Instance must have a Name tag."
  }
}
