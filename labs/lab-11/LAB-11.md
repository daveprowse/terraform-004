# ⚙️ Lab-11 - Checks, Preconditions, and Postconditions

## Test Commands

| Command | What It Tests | When It Runs |
|---------|---------------|--------------|
| `terraform plan` | Preconditions | Before resource creation |
| `terraform apply` | Preconditions + Postconditions | During resource creation |
| `terraform plan -refresh-only` | Check blocks | After resource creation |

## Test Locations

| Test Type | File | Line/Block |
|-----------|------|------------|
| Precondition | main.tf | aws_instance lifecycle |
| Postconditions (3) | main.tf | aws_instance lifecycle |
| Check blocks (5) | checks.tf | Multiple check blocks |

## One-Line Test Execution

```bash
# Test everything at once
terraform init && terraform apply && terraform plan -refresh-only

# Test and cleanup
terraform apply && terraform plan -refresh-only && terraform destroy
```

## Test Coverage

```
9 Total Tests:
├── 1 Precondition  (region validation)
├── 3 Postconditions (DNS, state, type)
└── 5 Check blocks  (health, config, SG, region, tags)
```

## Expected Test Flow

```
1. terraform apply
   ├── ✓ Precondition: Region = us-east-2
   ├── → Create security group
   ├── → Create instance
   ├── ✓ Postcondition: Has public DNS
   ├── ✓ Postcondition: State = running
   └── ✓ Postcondition: Type = t2.micro

2. terraform plan -refresh-only
   ├── ✓ Check: instance_health
   ├── ✓ Check: instance_configuration
   ├── ✓ Check: security_group_configuration
   ├── ✓ Check: instance_region
   └── ✓ Check: instance_tags
```

## Force Test Failures

```bash
# Fail precondition
echo 'aws_region = "us-east-1"' > terraform.tfvars
terraform plan

# Fail postcondition
# Edit main.tf: add associate_public_ip_address = false
terraform apply

# Fail check
aws ec2 stop-instances --instance-ids $(terraform output -raw instance_id)
terraform plan -refresh-only
```

## Debug Commands

```bash
# View state
terraform show

# View specific resource
terraform state show aws_instance.test_instance

# View check details
terraform plan -refresh-only -json | jq '.checks'

# Terraform console
terraform console
> aws_instance.test_instance.public_dns
```

## Cleanup

```bash
terraform destroy
```

---

> Note: See TESTING.md for in-depth, and more advanced testing.