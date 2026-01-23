# Refactoring Terraform State

## Overview

Refactoring Terraform state allows you to rename or restructure resources in your code without destroying and recreating them. This is critical for production environments where recreation would cause downtime or data loss. (And possibly *job* loss. Yikes!)

## Prerequisites
- Terraform 1.14.2 or later installed
- AWS CLI configured with valid credentials
- AWS account access
- VS Code or similar IDE

## Problem Statement

When you rename a resource in Terraform code, Terraform sees it as deleting the old resource and creating a new one. The `moved` block tells Terraform "this is the same resource, just with a new name" - preventing destruction.

## Steps

### 1. Navigate to Lab Directory

```bash
cd .../labs/lab-19/refactoring-terraform
```

### 2. Review Initial Configuration

Review in VS Code, or:

```bash
cat main.tf
```

You should see two IAM user resources: `dev_user_1` and `dev_user_2`.

### 3. Initialize and Apply

```bash
terraform init
terraform apply
```

Type `yes` when prompted. Two IAM users are created: `developer-alice` and `developer-bob`.

### 4. Verify State

```bash
terraform state list
```

Output:
```
aws_iam_user.dev_user_1
aws_iam_user.dev_user_2
```

> Note: For fun, check the "UserID" of one of the users and write it down for later. Use this command:
> ```
> aws iam get-user --user-name dev_user_1
> ```

### 5. Rename Resources WITHOUT Refactoring (See the Problem)

Edit `main.tf` and rename the resource identifiers `dev_user_1` and `dev_user_2`:

**Change this:**
```hcl
resource "aws_iam_user" "dev_user_1" {
  name = "developer-alice"
  
  tags = {
    team = "Engineering"
  }
}

resource "aws_iam_user" "dev_user_2" {
  name = "developer-bob"
  
  tags = {
    team = "Engineering"
  }
}
```

**To this:**
```hcl
resource "aws_iam_user" "engineer_alice" {
  name = "developer-alice"
  
  tags = {
    team = "Engineering"
  }
}

resource "aws_iam_user" "engineer_bob" {
  name = "developer-bob"
  
  tags = {
    team = "Engineering"
  }
}
```

Save your work.

### 6. Check the Plan (Observe Destruction)

```bash
terraform plan
```

**Output shows:**
```
Terraform will perform the following actions:

  # aws_iam_user.dev_user_1 will be destroyed
  - resource "aws_iam_user" "dev_user_1" {
      - name = "developer-alice"
    }

  # aws_iam_user.dev_user_2 will be destroyed
  - resource "aws_iam_user" "dev_user_2" {
      - name = "developer-bob"
    }

  # aws_iam_user.engineer_alice will be created
  + resource "aws_iam_user" "engineer_alice" {
      + name = "developer-alice"
    }

  # aws_iam_user.engineer_bob will be created
  + resource "aws_iam_user" "engineer_bob" {
      + name = "developer-bob"
    }

Plan: 2 to add, 0 to change, 2 to destroy.
```

**Problem:** Terraform wants to destroy and recreate users that already exist! Don't do it!

‼️ **DO NOT APPLY** - Cancel with `Ctrl+C`  ‼️

### 7. Fix with moved Block

Add `moved` blocks to your `main.tf` BEFORE the resource blocks:

```hcl
moved {
  from = aws_iam_user.dev_user_1
  to   = aws_iam_user.engineer_alice
}

moved {
  from = aws_iam_user.dev_user_2
  to   = aws_iam_user.engineer_bob
}

resource "aws_iam_user" "engineer_alice" {
  name = "developer-alice"
  
  tags = {
    team = "Engineering"
  }
}

resource "aws_iam_user" "engineer_bob" {
  name = "developer-bob"
  
  tags = {
    team = "Engineering"
  }
}
```

### 8. Check Plan Again (No Destruction!)

```bash
terraform plan
```

**Output shows:**
```
Terraform will perform the following actions:

  # aws_iam_user.dev_user_1 has moved to aws_iam_user.engineer_alice
    resource "aws_iam_user" "engineer_alice" {
        name = "developer-alice"
    }

  # aws_iam_user.dev_user_2 has moved to aws_iam_user.engineer_bob
    resource "aws_iam_user" "engineer_bob" {
        name = "developer-bob"
    }

Plan: 0 to add, 0 to change, 0 to destroy.
```

**Success!** No resources will be destroyed or created.

> Note: You will see that there are also no *changes* to be made. As of the writing of this lab, `moved` blocks do not show as changes in the Terraform plan.

### 9. Apply the Refactoring

```bash
terraform apply
```

Type `yes` when prompted. Terraform updates the state file to reflect the new names.

### 10. Verify Refactored State

```bash
terraform state list
```

Output now shows:
```
aws_iam_user.engineer_alice
aws_iam_user.engineer_bob
```

**Verify users still exist in AWS:**

Do this in the AWS console or:

```bash
aws iam get-user --user-name developer-alice
aws iam get-user --user-name developer-bob
```

Both users still exist - no recreation occurred!

> Note: Check the UserID for Alice against the UserID you wrote down previously (for `dev_user_1`), it should be the same!

### 11. Clean Up moved Blocks (Optional)

After successfully applying the `moved` blocks, you can remove them from your configuration. They're only needed during the refactoring transition.

**Edit main.tf and remove the moved blocks:**

```hcl
resource "aws_iam_user" "engineer_alice" {
  name = "developer-alice"
  
  tags = {
    team = "Engineering"
  }
}

resource "aws_iam_user" "engineer_bob" {
  name = "developer-bob"
  
  tags = {
    team = "Engineering"
  }
}
```

```bash
terraform plan
```

Output: `No changes. Your infrastructure matches the configuration.`

### 12. Destroy Resources

```bash
terraform destroy
```

Type `yes` when prompted.

## Key Concepts

**moved Block:**
- Tells Terraform a resource has been renamed/moved
- Prevents destruction and recreation
- Syntax: `moved { from = old_address, to = new_address }`
- Can be removed after successful refactoring

**When to Use:**
- Renaming resource identifiers
- Moving resources between modules
- Restructuring your Terraform code
- Splitting or combining resources

**State Operations:**
The `moved` block internally performs: `terraform state mv old_name new_name`

## Alternative: Manual State Commands

You can also refactor state using CLI commands instead of `moved` blocks:

```bash
# Rename in code first, then:
terraform state mv aws_iam_user.dev_user_1 aws_iam_user.engineer_alice
terraform state mv aws_iam_user.dev_user_2 aws_iam_user.engineer_bob
```

**Comparison:**

| Method | Pros | Cons |
|--------|------|------|
| `moved` block | Documented in code, team-friendly, version controlled | Requires Terraform 1.1+ |
| `state mv` command | Works in all versions, quick for one-off changes | Not documented, manual, error-prone |

## Common Use Cases

**Renaming for clarity:**
```hcl
moved {
  from = aws_instance.server
  to   = aws_instance.web_server
}
```

**Moving to module:**
```hcl
moved {
  from = aws_s3_bucket.data
  to   = module.storage.aws_s3_bucket.data
}
```

**Moving from module:**
```hcl
moved {
  from = module.old_network.aws_vpc.main
  to   = aws_vpc.main
}
```

## Important Notes

- `moved` blocks are declarative and version-controlled
- Always run `terraform plan` before `apply` to verify refactoring
- Refactoring doesn't change actual infrastructure
- Safe to remove `moved` blocks after successful apply
- Team members automatically get refactoring when they pull code

## Learn More

- moved block documentation: https://developer.hashicorp.com/terraform/language/modules/develop/refactoring
- State management: https://developer.hashicorp.com/terraform/cli/state
