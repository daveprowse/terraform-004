# Terraform Testing Documentation

## Overview

This project demonstrates Terraform's testing capabilities using:
1. **Lifecycle Preconditions** - Validate input conditions before resource creation
2. **Lifecycle Postconditions** - Verify resource state after creation
3. **Check Blocks** - Continuous validation of resource health and configuration

## Project Structure

```
terraform-testing-demo/
├── main.tf           # Main infrastructure with lifecycle conditions
├── checks.tf         # Check blocks for health validation
├── variables.tf      # Input variables
├── outputs.tf        # Output values
└── TESTING.md        # This file
```

## Test Types Explained

### 1. Lifecycle Preconditions

**What**: Validate conditions BEFORE resource creation
**When**: Runs during `terraform plan` and `terraform apply`
**Purpose**: Catch configuration errors early

**Example in this project**:
```hcl
lifecycle {
  precondition {
    condition     = var.aws_region == "us-east-2"
    error_message = "Instance must be created in us-east-2 region."
  }
}
```

**Location**: `main.tf` (inside `aws_instance.test_instance` resource)

### 2. Lifecycle Postconditions

**What**: Validate resource state AFTER creation
**When**: Runs during `terraform apply` after resource is created
**Purpose**: Ensure resource meets expected criteria

**Examples in this project**:
```hcl
lifecycle {
  postcondition {
    condition     = self.public_dns != ""
    error_message = "Instance must have a public DNS name."
  }
  
  postcondition {
    condition     = self.instance_state == "running"
    error_message = "Instance must be in running state."
  }
}
```

**Location**: `main.tf` (inside `aws_instance.test_instance` resource)

### 3. Check Blocks

**What**: Continuous validation of infrastructure health
**When**: Runs during `terraform plan -refresh-only` or `terraform apply -refresh-only`
**Purpose**: Monitor infrastructure drift and health

**Examples in this project**:
- Instance health check
- Configuration validation
- Security group verification
- Region validation
- Tag validation

**Location**: `checks.tf` (5 separate check blocks)

## Running Tests

### Prerequisites

1. **AWS Credentials**: Configure AWS CLI or environment variables
   ```bash
   aws configure
   # OR
   export AWS_ACCESS_KEY_ID="your-key"
   export AWS_SECRET_ACCESS_KEY="your-secret"
   ```

2. **Terraform**: Version >= 1.5.0
   ```bash
   terraform version
   ```

### Initial Setup

```bash
# Initialize Terraform
terraform init
```

## Test Execution

### Test 1: Run ALL Tests Together (Recommended)

This runs preconditions, postconditions, and creates the infrastructure:

```bash
terraform apply
```

**What happens**:
1. ✓ Precondition validates region is us-east-2
2. → Creates security group
3. → Creates EC2 instance
4. ✓ Postcondition validates public DNS exists
5. ✓ Postcondition validates instance is running
6. ✓ Postcondition validates instance type matches
7. → Displays outputs

**Expected Output**:
```
Plan: 2 to add, 0 to change, 0 to destroy.

aws_security_group.test_sg: Creating...
aws_security_group.test_sg: Creation complete
aws_instance.test_instance: Creating...
aws_instance.test_instance: Still creating... [10s elapsed]
aws_instance.test_instance: Creation complete

Apply complete! Resources: 2 added, 0 changed, 0 destroyed.

Outputs:
instance_id = "i-0123456789abcdef0"
instance_public_dns = "ec2-xx-xxx-xxx-xxx.us-east-2.compute.amazonaws.com"
...
```

### Test 2: Validate Preconditions Only

Test preconditions without creating infrastructure:

```bash
terraform plan
```

**What happens**:
- ✓ Validates region is us-east-2
- Shows planned resources
- Does NOT create anything

**To test precondition failure**, temporarily change region:

```bash
# Create terraform.tfvars
echo 'aws_region = "us-east-1"' > terraform.tfvars

# Run plan
terraform plan
```

**Expected Output**:
```
Error: Resource precondition failed

  on main.tf line XX:
  XX:     precondition {

Instance must be created in us-east-2 region. Current region: us-east-1
```

**Reset**:
```bash
rm terraform.tfvars
```

### Test 3: Validate Postconditions

Postconditions run automatically during `terraform apply`. To see them in action:

```bash
terraform apply
```

**To test postcondition failure**, you would need to modify the resource to create it without a public IP (advanced):

```hcl
# In main.tf, add to aws_instance:
associate_public_ip_address = false
```

Then run:
```bash
terraform apply
```

**Expected Output**:
```
Error: Resource postcondition failed

  on main.tf line XX:
  XX:     postcondition {

Instance must have a public DNS name. Instance i-xxx does not have a public DNS assigned.
```

### Test 4: Run Check Blocks Only

After infrastructure is created, run health checks:

```bash
terraform plan -refresh-only
```

**What happens**:
- Refreshes state from AWS
- ✓ Runs all 5 check blocks
- ✓ Validates instance health
- ✓ Validates configuration
- ✓ Validates security group
- ✓ Validates region
- ✓ Validates tags
- Shows any drift or issues

**Expected Output**:
```
Check block execution: (5 checks)

- instance_health: pass
- instance_configuration: pass
- security_group_configuration: pass
- instance_region: pass
- instance_tags: pass

All checks passed
```

**Alternative command** (also runs checks):
```bash
terraform apply -refresh-only
```

### Test 5: Run Specific Check Block

Terraform doesn't support running individual check blocks, but you can:

**Option 1**: Comment out other checks in `checks.tf`

**Option 2**: Use grep to see specific check results:
```bash
terraform plan -refresh-only 2>&1 | grep -A 10 "instance_health"
```

### Test 6: Force Check Failure (For Testing)

1. **Stop the instance** (to fail health check):
   ```bash
   # Get instance ID from outputs
   terraform output instance_id
   
   # Stop the instance
   aws ec2 stop-instances --instance-ids i-xxxxxxxxxxxxx
   
   # Wait a moment, then run checks
   terraform plan -refresh-only
   ```

   **Expected Output**:
   ```
   Check block execution: (5 checks)
   
   - instance_health: fail
     - Instance i-xxx is not in running state. Current state: stopped
   ```

2. **Restart the instance**:
   ```bash
   aws ec2 start-instances --instance-ids i-xxxxxxxxxxxxx
   terraform plan -refresh-only  # Should pass again
   ```

### Test 7: Continuous Monitoring

Set up a loop to continuously check health:

```bash
# Check every 30 seconds
while true; do
  echo "=== Check at $(date) ==="
  terraform plan -refresh-only -compact-warnings
  sleep 30
done
```

Press `Ctrl+C` to stop.

## Test Scenarios

### Scenario 1: Happy Path (All Tests Pass)

```bash
terraform init
terraform apply      # All preconditions and postconditions pass
terraform plan -refresh-only  # All checks pass
```

### Scenario 2: Precondition Failure

```bash
# Set wrong region
echo 'aws_region = "us-east-1"' > terraform.tfvars
terraform plan       # FAILS at precondition
rm terraform.tfvars
```

### Scenario 3: Postcondition Failure

```bash
# Modify main.tf to disable public IP
# Then apply - will fail at postcondition
terraform apply
```

### Scenario 4: Check Failure During Operations

```bash
terraform apply                    # Deploy successfully
aws ec2 stop-instances --instance-ids $(terraform output -raw instance_id)
terraform plan -refresh-only       # Check FAILS
aws ec2 start-instances --instance-ids $(terraform output -raw instance_id)
terraform plan -refresh-only       # Check PASSES
```

## Understanding Test Results

### Successful Precondition
```
✓ Precondition passed (no output shown)
→ Terraform proceeds with planning
```

### Failed Precondition
```
Error: Resource precondition failed
  on main.tf line XX
  
[Error message explaining what failed]
```

### Successful Postcondition
```
✓ Postcondition passed (no output shown)
→ Resource creation completes
```

### Failed Postcondition
```
Error: Resource postcondition failed
  on main.tf line XX
  
[Error message explaining what failed]
→ Resource may be created but in unexpected state
```

### Successful Check
```
Check block execution:
- check_name: pass
```

### Failed Check
```
Check block execution:
- check_name: fail
  - [Specific assertion that failed]
```

## Testing Best Practices

### 1. Development Workflow
```bash
# 1. Validate syntax
terraform validate

# 2. Check preconditions
terraform plan

# 3. Deploy and validate postconditions
terraform apply

# 4. Run health checks
terraform plan -refresh-only

# 5. Make changes
# ... edit files ...

# 6. Repeat
terraform plan
terraform apply
```

### 2. CI/CD Integration
```bash
# In CI pipeline
terraform init -backend-config="..." 
terraform validate
terraform plan -out=tfplan
terraform apply tfplan
terraform plan -refresh-only  # Validate deployment
```

### 3. Debugging Failed Tests

**Precondition failures**:
```bash
# Check variable values
terraform console
> var.aws_region
> var.instance_type
```

**Postcondition failures**:
```bash
# Examine resource in state
terraform show
terraform state show aws_instance.test_instance
```

**Check failures**:
```bash
# Get detailed check output
terraform plan -refresh-only -json | jq '.checks'

# Check AWS console for resource state
aws ec2 describe-instances --instance-ids i-xxx
```

## Cleanup

### Remove Infrastructure
```bash
terraform destroy
```

### Complete Cleanup
```bash
terraform destroy
rm -rf .terraform/
rm .terraform.lock.hcl
rm terraform.tfstate*
```

## Test Coverage Summary

| Test Type | Count | What It Validates |
|-----------|-------|-------------------|
| Preconditions | 1 | Region is us-east-2 |
| Postconditions | 3 | DNS name, running state, instance type |
| Check Blocks | 5 | Health, config, security, region, tags |
| **Total** | **9** | **Comprehensive validation** |

## Advanced Testing

### Test with Different Instance Types

```bash
# Test with t2.micro (default)
terraform apply

terraform destroy

# Test with t3.micro
echo 'instance_type = "t3.micro"' > terraform.tfvars
terraform apply

terraform destroy
rm terraform.tfvars
```

### Test Variable Validation

```bash
# Try invalid instance type
echo 'instance_type = "t2.large"' > terraform.tfvars
terraform plan  # FAILS variable validation

rm terraform.tfvars
```

## Troubleshooting

### Issue: Checks not showing in output
**Solution**: Ensure Terraform >= 1.5.0
```bash
terraform version
```

### Issue: Postcondition fails for public DNS
**Cause**: Instance created without public IP
**Solution**: Ensure default VPC has map_public_ip_on_launch enabled

### Issue: All checks show "unknown"
**Cause**: Instance not yet created
**Solution**: Run `terraform apply` first, then `terraform plan -refresh-only`

## Summary

This demo showcases three complementary testing approaches:

1. **Preconditions**: Catch errors before deployment
2. **Postconditions**: Validate deployment results
3. **Checks**: Monitor ongoing health

Together, they provide comprehensive testing coverage throughout the infrastructure lifecycle.
