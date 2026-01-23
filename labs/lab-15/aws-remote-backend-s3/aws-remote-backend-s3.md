# Mini-Lab: AWS S3 Backend for Terraform State

## Prerequisites
- AWS CLI configured with valid credentials
- Terraform 1.14.2 installed
- AWS account access

## Steps

### 1. Create S3 Bucket

**Option A: Using AWS CLI**

```bash
aws s3 mb s3://<bucket_name> --region us-east-2
```

**Option B: Using AWS Console**

1. Navigate to S3: https://console.aws.amazon.com/s3/
2. Click "Create bucket"
3. Bucket name: `<bucket_name>` (must be globally unique)
4. Region: `us-east-2`
5. Keep default settings
6. Click "Create bucket"

**IMPORTANT!** Replace `<bucket_name>` with a unique bucket name. In the next step you will reference this in the Terraform configuration file.

### 2. Reference the Bucket in Terraform Code

Go to the `aws-remote-backend.tf` file and change the bucket name from `"<bucket_name>"` to what you have selected. For example:

```hcl
bucket = "user-bucket1"
```

### 3. Initialize Terraform

```bash
terraform init
```

Terraform creates `dir1/key` path automatically in the bucket.

### 4. Validate Configuration

```bash
terraform validate
```

### 5. Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

### 6. View Remote State File in S3 Bucket

The state file (`terraform.tfstate`) is stored remotely in S3 instead of locally. This allows teams to share state and enables state locking.

**Using AWS Console:**

1. Navigate to S3: https://console.aws.amazon.com/s3/
2. Click bucket: `<bucket_name>`
3. Navigate to path: `dir1/`
4. Click on object: `key` (this is the remote `terraform.tfstate` file)
5. Click "Download" or "Open" to view state file contents

**Using AWS CLI:**

```bash
# List the remote state file
aws s3 ls s3://<bucket_name>/dir1/

# View the remote terraform.tfstate contents
aws s3 cp s3://<bucket_name>/dir1/key - | jq .
```

### 7. Verify IAM User Created

```bash
aws iam get-user --user-name user-42
```

Feel free to view the user in the IAM portion of the AWS console as well.

### 8. Destroy Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted.

**Note:** State file remains in S3 bucket after destroy.

### 9. Clean Up S3 Bucket

Remove the state file and delete the bucket:

```bash
aws s3 rm s3://<bucket_name>/dir1/key
aws s3 rb s3://<bucket_name>
```

## Key Concepts

- **bucket**: S3 bucket name where state is stored (must be globally unique)
- **key**: Path within bucket for state file (Terraform creates this automatically)
- **region**: AWS region for the S3 bucket
- Remote state enables team collaboration and state locking
- State file contains sensitive data - secure your S3 bucket appropriately

## Learn More

For more information about S3 buckets: https://docs.aws.amazon.com/AmazonS3/latest/userguide/Welcome.html