# Terraform Testing Documentation

## Test Files Location

All test files are in the `tests/` directory and use `command = plan` for validation without creating infrastructure.

### Validation Tests
- `unit_basic.tftest.hcl` - Resource counts and basic attributes
- `iam_validation.tftest.hcl` - IAM user names and tags
- `custom_variables.tftest.hcl` - Custom instance configuration

## Running Tests

### Run All Tests
```bash
terraform test
```

### Run Specific Test
```bash
terraform test -filter=tests/unit_basic.tftest.hcl
terraform test -filter=tests/iam_validation.tftest.hcl
terraform test -filter=tests/custom_variables.tftest.hcl
```

### Run with Verbose Output
```bash
terraform test -verbose
```

## Expected Results

### unit_basic.tftest.hcl
**Purpose**: Validates resource counts and basic attributes

**Expected Output**:
```
tests/unit_basic.tftest.hcl... in progress
  run "check_iam_user_count"... pass
  run "check_instance_type"... pass
  run "check_environment_tag"... pass
tests/unit_basic.tftest.hcl... tearing down
tests/unit_basic.tftest.hcl... pass
Success! 3 passed, 0 failed.
```

**Validations**:
- ✓ IAM user count = 3
- ✓ Instance type = t2.micro
- ✓ Environment tag = test

### iam_validation.tftest.hcl
**Purpose**: Validates IAM user names and tags

**Expected Output**:
```
tests/iam_validation.tftest.hcl... in progress
  run "check_user_1_exists"... pass
  run "check_user_2_exists"... pass
  run "check_user_3_exists"... pass
  run "check_all_users_tagged"... pass
tests/iam_validation.tftest.hcl... tearing down
tests/iam_validation.tftest.hcl... pass
Success! 4 passed, 0 failed.
```

**Validations**:
- ✓ test-user-1 exists
- ✓ test-user-2 exists
- ✓ test-user-3 exists
- ✓ All users have Environment tag = test

### custom_variables.tftest.hcl
**Purpose**: Validates custom instance configuration

**Expected Output**:
```
tests/custom_variables.tftest.hcl... in progress
  run "check_custom_instance_type"... pass
  run "check_custom_instance_name"... pass
tests/custom_variables.tftest.hcl... tearing down
tests/custom_variables.tftest.hcl... pass
Success! 2 passed, 0 failed.
```

**Validations**:
- ✓ Custom instance type = t3.small
- ✓ Custom instance name = custom-test-instance

### All Tests Combined
**Expected Output** when running `terraform test`:
```
tests/custom_variables.tftest.hcl... in progress
  run "check_custom_instance_type"... pass
  run "check_custom_instance_name"... pass
tests/custom_variables.tftest.hcl... tearing down
tests/custom_variables.tftest.hcl... pass

tests/iam_validation.tftest.hcl... in progress
  run "check_user_1_exists"... pass
  run "check_user_2_exists"... pass
  run "check_user_3_exists"... pass
  run "check_all_users_tagged"... pass
tests/iam_validation.tftest.hcl... tearing down
tests/iam_validation.tftest.hcl... pass

tests/unit_basic.tftest.hcl... in progress
  run "check_iam_user_count"... pass
  run "check_instance_type"... pass
  run "check_environment_tag"... pass
tests/unit_basic.tftest.hcl... tearing down
tests/unit_basic.tftest.hcl... pass

Success! 9 passed, 0 failed.
```

## Complete Workflow

### 1. Pre-Apply Validation
```bash
# Initialize
terraform init

# Run all tests
terraform test

# Expected: 9 total checks pass (no resources created)
```

### 2. Deploy Infrastructure
```bash
terraform plan
terraform apply
```

### 3. Post-Deploy Validation
For validating deployed infrastructure, use:
```bash
# Refresh state and check for drift
terraform plan -refresh-only

# Or refresh and update state
terraform apply -refresh-only
```

### 4. Cleanup
```bash
terraform destroy
```

## Test Failure Scenarios

Tests will display specific error messages when they fail:

```
  run "check_iam_user_count"... fail
Error: Test assertion failed
  on tests/unit_basic.tftest.hcl line X:
  Expected 3 IAM users, got 2
```

## Important Notes

### Test Characteristics
- All tests use `command = plan` (no infrastructure created)
- Tests validate configuration only
- No AWS credentials required to run tests
- Each `run` block appears as a separate line in output
- Tests automatically tear down after completion

### Best Practices
1. Run `terraform test` before `terraform apply`
2. Tests validate configuration correctness
3. Use `terraform plan -refresh-only` to validate deployed infrastructure
4. Use `-verbose` flag for detailed execution logs

---
## EXCELLENT!!

---

## Extra Credit

For more information on testing, see this excellent article: https://www.hashicorp.com/en/blog/testing-hashicorp-terraform
