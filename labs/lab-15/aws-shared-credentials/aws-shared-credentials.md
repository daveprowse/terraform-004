# Mini-Lab: AWS Shared Credentials in Terraform

## Prerequisites
- AWS CLI configured with valid credentials
- Terraform 1.14.2 installed
- AWS account access

## Steps

### 1. Review the Configuration File

Do this in VS Code in Lab 15 or:

```bash
cat aws-shared-credentials.tf
```

### 2. Backup Existing Credentials File

```bash
cd ~/.aws
cp credentials credentials.bak
```

### 3. Modify Credentials File to Add [prod] Profile

Edit `~/.aws/credentials`:

```ini
[default]
aws_access_key_id = YOUR_DEFAULT_ACCESS_KEY
aws_secret_access_key = YOUR_DEFAULT_SECRET_KEY

[prod]
aws_access_key_id = YOUR_PROD_ACCESS_KEY
aws_secret_access_key = YOUR_PROD_SECRET_KEY
```

### 4. Initialize and Apply Terraform

```bash
cd /path/to/terraform/project
terraform init
terraform validate
terraform apply
```

Type `yes` when prompted.

> Note: I like to use multiple terminals in VS Code. You can create additional terminals with:
> ```
> Ctrl+Shift`
> ```
> And switch between them with `Ctrl+PgUp` and `Ctrl+PgDn`.

### 5. View IAM User in AWS Console

1. Navigate to IAM console: https://console.aws.amazon.com/iam/
2. Click "Users" in left sidebar
3. Verify "test-user" exists with "department = OPS" tag

### 6. Destroy Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted.

### 7. Revert to Original Credentials File

```bash
cd ~/.aws
mv credentials.bak credentials
```

## Verification

Confirm credentials file restored:

```bash
cat ~/.aws/credentials
```