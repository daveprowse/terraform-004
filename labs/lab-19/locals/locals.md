# Local Values

## Overview

Local values (locals) assign names to expressions, making configurations more readable and maintainable. Instead of repeating the same values or expressions throughout your code, you define them once in a `locals` block and reference them multiple times. RE-USE!!!

## Prerequisites

- Terraform 1.14.2 or later installed
- AWS CLI configured with valid credentials
- AWS account access
- VS Code (recommended)

## Steps

### 1. Navigate to Lab Directory

```bash
cd .../labs/lab-19/locals
```

### 2. Review Starter Code

**Using VS Code:**
- Open the `locals` directory in VS Code
- View `main.tf`

**Using terminal:**

```bash
cat main.tf
```

You should see the base configuration with placeholders for locals blocks and IAM resource.

### 3. Add Locals Block for User Names

Add the following locals block after the `provider` block:

```hcl
locals {
  accounts = toset(["Alice", "Bob", "Charlie", "Denise"])
}
```

**What this does:**

- Defines a local value named `accounts`
- Contains a set of 4 user names
- Can be referenced as `local.accounts` throughout the configuration

### 4. Add Locals Block for Common Tags

Add another locals block below the first one:

```hcl
locals {
  common_tags = {
    department  = "Engineering"
    environment = "Production"
    managed_by  = "Terraform"
  }
}
```

**What this does:**
- Defines common tags to apply across resources
- Promotes consistency and reduces duplication
- Centralized location for tag management

### 5. Add IAM User Resource with Locals References

Add the IAM user resource referencing both locals blocks:

```hcl
resource "aws_iam_user" "team_members" {
  for_each = local.accounts
  name     = each.key

  tags = local.common_tags
}
```

**What this does:**
- Uses `for_each` to iterate over `local.accounts`
- Creates one IAM user per name in the set
- Applies `local.common_tags` to all users

### 6. Review Complete Configuration

Your complete `main.tf` should look like:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }

  required_version = ">= 1.14.2"
}

provider "aws" {
  region = "us-east-2"
}

locals {
  accounts = toset(["Alice", "Bob", "Charlie", "Denise"])
}

locals {
  common_tags = {
    department  = "Engineering"
    environment = "Production"
    managed_by  = "Terraform"
  }
}

resource "aws_iam_user" "team_members" {
  for_each = local.accounts
  name     = each.key

  tags = local.common_tags
}
```

### 7. Initialize Terraform

```bash
terraform init
```

### 8. Validate Configuration

```bash
terraform validate
```

### 9. Preview Changes

```bash
terraform plan
```

You should see 4 IAM users will be created, each with the common tags.

### 10. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

### 11. Verify Users Created

First, check in the AWS console. Verify the user names and the tags.

```bash
terraform state list
```

Output:
```
aws_iam_user.team_members["Alice"]
aws_iam_user.team_members["Bob"]
aws_iam_user.team_members["Charlie"]
aws_iam_user.team_members["Denise"]
```

**Check tags using AWS CLI:**

```bash
aws iam list-user-tags --user-name Alice
```

You should see the common tags applied.

### 12. Destroy Resources

```bash
terraform destroy
```

Type `yes` when prompted.

## Key Concepts

**Local Values:**
- Assigned once, referenced many times
- Syntax: `local.name_of_local`
- Cannot be overridden or reassigned
- Evaluated during planning phase

**Benefits:**
- **DRY Principle**: Don't Repeat Yourself
- **Maintainability**: Change once, update everywhere
- **Readability**: Descriptive names improve code clarity
- **Complex Expressions**: Simplify complicated logic

## locals vs variables

| Feature | locals | variables |
|---------|--------|-----------|
| Set by | Internal expressions | External input |
| Can change | No (within config) | Yes (via tfvars, CLI, etc.) |
| Scope | Configuration file | Across configurations |
| Use case | Derived values | User inputs |

## Best Practices

- Use locals for computed values and transformations
- Use variables for values that differ between environments
- Group related locals together in the same block
- Use descriptive names (e.g., `common_tags` not `tags1`)
- Avoid overusing locals for simple, one-time values

## Additional Examples

**Environment-specific naming:**
```hcl
locals {
  name_prefix = "${var.environment}-${var.project}"
}

resource "aws_s3_bucket" "data" {
  bucket = "${local.name_prefix}-data-bucket"
}
```

In this case the locals block refers to variables.

**Tag merging:**
```hcl
locals {
  default_tags = {
    managed_by = "Terraform"
    project    = "web-app"
  }
}

resource "aws_instance" "web" {
  tags = merge(local.default_tags, {
    Name = "web-server"
    Role = "frontend"
  })
}
```

## Learn More

- Locals documentation: https://developer.hashicorp.com/terraform/language/values/locals
