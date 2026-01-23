# The for_each Meta-Argument

## Overview

The `for_each` meta-argument creates multiple instances of a resource based on a map or set of values. Instead of copying the same resource block multiple times, `for_each` allows you to define it once and iterate over a collection.

## Prerequisites

- Terraform 1.14.2 or later installed
- AWS CLI configured with valid credentials
- AWS account access

## Steps

### 1. Navigate to Lab Directory

Make sure you are working in the `lab-18/for_each` directory.

### 2. Review Existing Code

Review the main.tf in VS Code or in the terminal:

```bash
cat main.tf
```

You should see the base configuration with a commented placeholder for the IAM user resource.

### 3. Add for_each Resource Block

Add the following code after the `provider` block:

```hcl
resource "aws_iam_user" "accounts" {
  for_each = toset(["Alice", "Bob", "Charlie", "Denise"])
  name     = each.key

  tags = {
    time_created = timestamp()    
    department   = "OPS"
  }
}
```

> Note: For good practice, actually type the entire resource block. 

**Code breakdown:**

- `for_each = toset([...])` - Converts list to set and iterates over each value
- `each.key` - Current item from the set (user name)
- Creates 4 separate IAM users from one resource block

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Validate Configuration

```bash
terraform validate
```

### 6. Preview Changes

```bash
terraform plan
```

You should see 4 IAM users will be created:
- `aws_iam_user.accounts["Alice"]`
- `aws_iam_user.accounts["Bob"]`
- `aws_iam_user.accounts["Charlie"]`
- `aws_iam_user.accounts["Denise"]`

### 7. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

### 8. Verify Users in AWS Console

1. Navigate to IAM: https://console.aws.amazon.com/iam/
2. Click **Users** in left sidebar
3. Verify all 4 users exist with `department = OPS` tag

**Using AWS CLI:**

```bash
aws iam list-users --query 'Users[?contains(UserName, `Alice`) || contains(UserName, `Bob`) || contains(UserName, `Charlie`) || contains(UserName, `Denise`)].UserName'
```

### 9. View State

```bash
terraform state list
```

Output shows each user as a separate resource instance:
```
aws_iam_user.accounts["Alice"]
aws_iam_user.accounts["Bob"]
aws_iam_user.accounts["Charlie"]
aws_iam_user.accounts["Denise"]
```

### 10. Destroy Resources

```bash
terraform destroy
```

Type `yes` when prompted.

## Key Concepts

- **for_each**: Creates multiple resource instances from a single block
- **toset()**: Converts a list to a set (removes duplicates, unordered)
- **each.key**: References the current item in the iteration
- **each.value**: Used when iterating over maps (not needed for sets)

## Advantages of for_each

- Write once, create many resources
- Easy to add/remove items from the collection
- Each instance has a unique identifier in state
- More maintainable than duplicating resource blocks

## Additional Examples

Using `for_each` in a variable block:

```hcl
resource "azurerm_subnet" "snets" {
    for_each = var.subnets
    name = each.key
```

Using `for_each` in a resource that refers to a locals block:

```hcl
locals {
  ip_addresses = ["10.0.0.1", "10.0.0.2"]
}

resource "example" "example" {
  for_each   = toset(local.ip_addresses)
  ip_address = each.key
}
```

## Learn More

- for_each documentation: https://developer.hashicorp.com/terraform/language/meta-arguments/for_each
- toset function: https://developer.hashicorp.com/terraform/language/functions/toset
