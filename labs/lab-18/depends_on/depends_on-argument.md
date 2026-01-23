# The depends_on Meta-Argument

## Overview

The `depends_on` meta-argument explicitly defines dependencies between resources. It forces Terraform to create resources in a specific order, even when no implicit dependency exists.

## Prerequisites

- Terraform 1.14.2 or later installed
- AWS CLI configured with valid credentials
- AWS account access

## Steps

### 1. Navigate to Lab Directory

Make sure you are working in the `lab-18/depends_on` directory.

### 2. Review Existing Code

Review the main.tf in VS Code or in the terminal:

```bash
cat main.tf
```

You should see an EC2 instance and IAM users but no explicit dependency... yet!

### 3. Add depends_on Block

Add the following `depends_on` block inside the `aws_iam_user` resource:

```hcl
resource "aws_iam_user" "accounts_3" {
  for_each = toset(["Indigo", "Violet"])
  name     = each.key

  depends_on = [aws_instance.computer_1]
}
```

> Note: Type out the code so that you can see the automatic options that VS Code gives you (and for practice!)

**What this does:**

- Forces Terraform to create the EC2 instance **before** creating IAM users
- Creates an explicit dependency where none naturally exists
- Ensures predictable resource creation order

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Preview the Execution Plan

```bash
terraform plan
```

**Observe the order:**
- Terraform will show the instance creation first
- IAM users will be created after the instance

### 6. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

**Watch the output carefully:**
```
aws_instance.computer_1: Creating...
aws_instance.computer_1: Still creating... [10s elapsed]
aws_instance.computer_1: Still creating... [20s elapsed]
aws_instance.computer_1: Creation complete after 25s

aws_iam_user.accounts_3["Indigo"]: Creating...
aws_iam_user.accounts_3["Violet"]: Creating...
aws_iam_user.accounts_3["Indigo"]: Creation complete after 1s
aws_iam_user.accounts_3["Violet"]: Creation complete after 1s
```

**Analysis:**
- EC2 instance creates first (typically takes ~20-30 seconds)
- IAM users wait for instance to complete
- IAM users create only after instance is ready

### 7. Verify Resources Created

```bash
terraform state list
```

Output:
```
aws_iam_user.accounts_3["Indigo"]
aws_iam_user.accounts_3["Violet"]
aws_instance.computer_1
```

### 8. View Dependency Graph (Optional)

```bash
terraform graph | dot -Tpng > graph.png
```

> Note: This is *optional* as we have not covered the `terraform graph` command yet, and because it requires the `dot` program be installed. 

Opens `graph.png` to visualize the dependency relationship.

### 9. Observe Destruction Order

```bash
terraform destroy
```

Type `yes` when prompted.

**Watch the output:**
```
aws_iam_user.accounts_3["Indigo"]: Destroying...
aws_iam_user.accounts_3["Violet"]: Destroying...
aws_iam_user.accounts_3["Indigo"]: Destruction complete
aws_iam_user.accounts_3["Violet"]: Destruction complete

aws_instance.computer_1: Destroying...
aws_instance.computer_1: Still destroying... [10s elapsed]
aws_instance.computer_1: Destruction complete after 15s
```

**Analysis:**
- Destruction happens in **reverse order**
- IAM users destroyed first
- EC2 instance destroyed last

## Key Concepts

**Implicit vs Explicit Dependencies:**
- **Implicit**: Terraform detects automatically (e.g., using resource attributes)
- **Explicit**: Defined manually with `depends_on`

**When to Use depends_on:**
- Cross-resource dependencies that Terraform can't detect
- Ensuring specific creation order for business logic
- Working around provider limitations
- Dependencies across different providers

**Syntax:**
```hcl
depends_on = [
  resource_type.resource_name,
  resource_type.another_resource
]
```

## Additional Examples

The example we covered in the lab is a basic one. Here are some more "real-world" examples.

**Database before application:**

```hcl
resource "aws_instance" "app_server" {
  depends_on = [aws_db_instance.database]
}
```

**Security group before instance:**

```hcl
resource "aws_instance" "web" {
  depends_on = [aws_security_group.allow_http]
}
```

**Module dependencies:**

```hcl
module "app" {
  depends_on = [module.networking, module.database]
}
```

## Important Notes

- Use `depends_on` sparingly - prefer implicit dependencies when possible
- Overuse can slow down Terraform operations
- Does not pass data between resources (use resource attributes for that)
- Applies to both creation and destruction order

## Learn More

- depends_on documentation: https://developer.hashicorp.com/terraform/language/meta-arguments/depends_on
