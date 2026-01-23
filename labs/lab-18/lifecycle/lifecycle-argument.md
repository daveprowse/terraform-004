# The lifecycle Meta-Argument

## Overview

The `lifecycle` meta-argument controls Terraform's behavior during resource creation, updates, and deletion. The `prevent_destroy` argument protects critical resources from accidental deletion.

## Prerequisites

- Terraform 1.14.2 or later installed
- AWS CLI configured with valid credentials
- AWS account access

## Steps

### 1. Navigate to Lab Directory

Make sure you are working in the `lab-18/lifecycle` directory.

### 2. Review Existing Code

Review the main.tf in VS Code or in the terminal:

```bash
cat main.tf
```

You should see the base configuration with IAM users but no lifecycle block.

### 3. Add lifecycle Block

Add the following lifecycle block inside the `aws_iam_user` resource:

```hcl
resource "aws_iam_user" "accounts_2" {
  for_each = toset(["Ernie", "Frank", "Gina", "Harry"])
  name     = each.key

  lifecycle {
    prevent_destroy = true
  }
}
```

> Note: Type out the code so that you can see the automatic options that VS Code gives you (and for practice!)

**What this does:**

- `prevent_destroy = true` - Blocks Terraform from destroying this resource
- Protects against accidental deletion of critical infrastructure

### 4. Initialize and Validate Terraform

```bash
terraform init
```

```bash
terraform validate
```

### 5. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted. This creates 4 IAM users with deletion protection enabled.

### 6. Verify Users Created

```bash
terraform state list
```

You should see:
```
aws_iam_user.accounts_2["Ernie"]
aws_iam_user.accounts_2["Frank"]
aws_iam_user.accounts_2["Gina"]
aws_iam_user.accounts_2["Harry"]
```

### 7. Attempt to Destroy Resources

```bash
terraform destroy
```

### 8. Analyze the Error

You should see an error similar to:

```
Error: Instance cannot be destroyed

  on main.tf line 21:
  21: resource "aws_iam_user" "accounts_2" {

Resource aws_iam_user.accounts_2["Ernie"] has lifecycle.prevent_destroy
set, but the plan calls for this resource to be destroyed. To avoid this
error and continue with the plan, either disable lifecycle.prevent_destroy
or reduce the scope of the plan using the -target flag.
```

**Analysis:**
- Terraform **refuses** to destroy resources with `prevent_destroy = true`
- This is intentional protection against accidental deletion
- Common use cases: databases, production resources, stateful services

### 9. Remove Protection and Destroy

To actually destroy the resources:

**Edit main.tf and remove or comment out the lifecycle block:**

```hcl
resource "aws_iam_user" "accounts_2" {
  for_each = toset(["Ernie", "Frank", "Gina", "Harry"])
  name     = each.key

  # lifecycle {
  #   prevent_destroy = true
  # }
}
```

**Or set it to false:**

```hcl
  lifecycle {
    prevent_destroy = false
  }
```

### 10. Apply and Destroy

```bash
terraform apply
terraform destroy
```

Type `yes` when prompted. Resources will now be destroyed successfully.

## Key Concepts

**lifecycle Arguments:**
- `prevent_destroy` - Blocks resource destruction
- `create_before_destroy` - Creates replacement before destroying original
- `ignore_changes` - Ignores changes to specified attributes
- `replace_triggered_by` - Forces replacement when specified resources change

**Common Use Cases for prevent_destroy:**
- Production databases
- S3 buckets with important data
- Load balancers in production
- Any resource where accidental deletion would cause major issues

## Best Practices

- Use `prevent_destroy = true` on production resources
- Document why protection is enabled
- Review protected resources regularly
- Use with state locking to prevent concurrent modifications

## Learn More

- lifecycle documentation: https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle
