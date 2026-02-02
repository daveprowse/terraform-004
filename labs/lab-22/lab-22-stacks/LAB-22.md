# ⚙️ Lab 22 - Terraform Stacks

**Objective:** Learn how to use Terraform Stacks to deploy the same infrastructure across multiple environments using HCP Terraform.

**Time:** ~10 minutes

**Prerequisites:**
- HCP Terraform account (formerly Terraform Cloud): https://app.terraform.io
- AWS account with credentials
- Terraform CLI >= 1.9.0

---

## What are Terraform Stacks?

Terraform Stacks let you deploy the same configuration to multiple environments (dev, staging, prod) with different input values. Each deployment has its own isolated state.

**Key concepts:**
- **Component** - A reusable Terraform module 
- **Deployment** - An instance of your stack (dev, prod, etc.)
- **Stack** - The complete configuration that can be deployed multiple times

---

## Lab Steps

### 1. Create HCP Terraform Organization and Project

1. Go to HCP Terraform: https://app.terraform.io
2. Create an organization (if you don't have one)
3. Create a new project called **lab-22-stacks**

### 2. Authenticate with HCP Terraform

Before working with Stacks, authenticate your CLI with HCP Terraform:

```bash
terraform login
```

Follow the prompts:
1. Press Enter to open browser
2. Generate an API token
3. Paste token back into terminal

**Expected output:**
```
Success! Terraform has obtained and saved an API token.
```

### 3. Review the Stack Structure

**File structure:**
```
lab-22-stacks/
├── .terraform-version           # Specifies Terraform version
├── stack.tfcomponent.hcl        # Component configuration
└── deployments.tfdeploy.hcl     # Deployment configuration
```

**What each file does:**
- `.terraform-version` - Specifies required Terraform version (1.14.2 - **update to YOUR local version**)
- `stack.tfcomponent.hcl` - Defines the IAM user component using a registry module
- `deployments.tfdeploy.hcl` - Defines dev and prod deployments with `store` block referencing AWS credentials variable set

**Update Terraform Version:**

Before initializing, update `.terraform-version` to match your local Terraform CLI:

```bash
# Check your Terraform version
terraform version

# Update .terraform-version file with your version
echo "1.x.x" > .terraform-version  # Replace 1.x.x with your actual version
```

**Example:** If `terraform version` shows `Terraform v1.10.3`, use `echo "1.10.3" > .terraform-version`

### 4. Initialize the Stack

Before creating the stack in HCP Terraform, initialize it locally to download required providers and modules:

```bash
# Navigate to lab directory
cd lab-22-stacks

# Initialize the stack (downloads providers and modules from registry)
terraform stacks init
```

**Expected output:**
```
Initializing modules...
Downloading terraform-aws-modules/iam/aws 6.3.0 for iam_users["alice"]...
...
Terraform Stacks has been successfully initialized!
```

**What this does:**
- Downloads the AWS provider
- Downloads the IAM module from Terraform Registry
- Prepares the stack for upload to HCP Terraform

### 5. Configure AWS Credentials

**IMPORTANT:** Configure AWS credentials BEFORE creating the stack, otherwise deployments will fail.

**This lab uses static AWS credentials (Option A).** HCP Terraform needs AWS credentials to create resources.

**Option A: Static Credentials (Used in this lab)**

1. In HCP Terraform, go to your project: **Projects** → **lab-22-stacks**
2. Click **Settings** → **Variable sets**
3. Click **Create variable set**
4. Name it: **AWS Credentials**
5. Add two **environment variables**:
   - Variable: `AWS_ACCESS_KEY_ID`
   - Value: (your AWS access key)
   - Check: ☑ Sensitive
   
   - Variable: `AWS_SECRET_ACCESS_KEY`
   - Value: (your AWS secret key)
   - Check: ☑ Sensitive
6. **CRITICAL:** Under "Variable set scope", select **"Apply to the entire project"**
7. **Verify:** Under "Applied to", you should see **"lab-22-stacks (project)"**
8. Click **Create variable set**

**Why static credentials for this lab?**
- Simpler setup (no additional AWS IAM configuration needed)
- Works immediately with just AWS keys
- **IMPORTANT:** Terraform Stacks require a `store` block in `deployments.tfdeploy.hcl` to reference variable sets (unlike regular workspaces which automatically use environment variables)
- The lab files include this `store` block that references your "AWS Credentials" variable set

**Option B: OIDC Dynamic Credentials (Production recommended, NOT used in this lab)**

OIDC provides short-lived, automatically rotating credentials without storing static keys. To use OIDC instead:

1. Configure AWS IAM OIDC trust relationship (follow: https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/aws-configuration)
2. Add this block to `deployments.tfdeploy.hcl`:
   ```hcl
   identity_token "aws" {
     audience = ["aws.workload.identity"]
   }
   ```
3. Remove static AWS credentials from variable sets

**Note:** If you see errors about "no EC2 IMDS role found" or "failed to refresh cached credentials," possible causes:
1. Missing or incorrect `store` block in `deployments.tfdeploy.hcl` (required for static credentials)
2. Variable set name in `store` block doesn't match HCP Terraform variable set name
3. Using `identity_token` block without configuring AWS OIDC trust relationship
- **Solution for this lab:** Use the provided files with `store` block that reference "AWS Credentials" variable set

### 5a. Understanding the Store Block (Static Credentials)

**Key Difference from Regular Workspaces:** Terraform Stacks don't automatically use environment variables like `AWS_ACCESS_KEY_ID`. Instead, you must explicitly reference variable sets using a `store` block.

**Review the provided `deployments.tfdeploy.hcl`:**

```hcl
store "varset" "aws_creds" {
  name     = "AWS Credentials"  # Must match your variable set name exactly
  category = "env"
}

deployment "development" {
  inputs = {
    aws_region     = "us-east-2"
    environment    = "dev"
    user_names     = ["alice", "bob"]
    aws_access_key = store.varset.aws_creds.AWS_ACCESS_KEY_ID
    aws_secret_key = store.varset.aws_creds.AWS_SECRET_ACCESS_KEY
  }
}
```

**What this does:**
1. `store` block declares access to variable set named "AWS Credentials"
2. Each deployment references credentials: `store.varset.aws_creds.AWS_ACCESS_KEY_ID`
3. Credentials passed as inputs to stack components
4. Provider in `stack.tfcomponent.hcl` uses these input variables

**IMPORTANT:** The `name = "AWS Credentials"` must exactly match your variable set name in HCP Terraform (case-sensitive). If you named yours differently, update the `store` block.

### 6. Create the Stack in HCP Terraform

Now create an empty stack using the Terraform CLI:

```bash
terraform stacks create \
  -organization-name YOUR_ORG_NAME \
  -project-name lab-22-stacks \
  -stack-name lab-22-stacks
```

**Expected output:**
```
Stack created successfully.
```

This creates an empty stack in HCP Terraform that's ready to receive your configuration.

### 7. Upload Stack Configuration

Upload your stack configuration to HCP Terraform:

```bash
terraform stacks configuration upload \
  -organization-name YOUR_ORG_NAME \
  -project-name lab-22-stacks \
  -stack-name lab-22-stacks
```

**Expected output:**
```
Uploading configuration...
Configuration uploaded successfully.
```

**What this does:**
- Uploads `.tfcomponent.hcl` and `.tfdeploy.hcl` files
- HCP Terraform validates the configuration
- Creates a configuration version
- Prepares deployments (dev and prod)

### 8. Verify Stack in HCP Terraform UI

1. Go to https://app.terraform.io
2. Navigate to: **Projects** → **lab-22-stacks** → **Stacks** → **lab-22-stacks**
3. You should see:
   - Stack overview
   - Two deployments: **development** and **production**
   - Configuration version status

### 9. Review and Apply Deployments

After uploading configuration, HCP Terraform automatically creates plans for each deployment.

**In HCP Terraform UI:**

1. Go to your Stack: **Stacks** → **lab-22-stacks**
2. Click the **Deployments** tab
3. You'll see two deployments with plans ready:
   - **development** - Will create 2 users (dev-alice, dev-bob)
   - **production** - Will create 3 users (prod-alice, prod-bob, prod-charlie)

### 10. Apply Development Deployment

1. Click on the **development** deployment
2. Review the planned resources (2 IAM users)
3. Approve/Apply the plan
4. Wait for apply to complete
5. Verify in AWS Console: **IAM** → **Users**
   - You should see: `dev-alice` and `dev-bob`

### 11. Apply Production Deployment

1. Go back to Stack deployments view
2. Click on the **production** deployment
3. Review the planned resources (3 IAM users)
4. Approve/Apply the plan
5. Wait for apply to complete
6. Verify in AWS Console:
   - You should see: `prod-alice`, `prod-bob`, `prod-charlie`

### 12. Review Outputs

In each deployment's timeline, open the Apply and view the Outputs:

```
user_arns = {
  "alice" = "arn:aws:iam::123456789012:user/dev-alice"
  "bob"   = "arn:aws:iam::123456789012:user/dev-bob"
}
```

### 13. Observe Key Stack Features

**Isolated State:**
- Each deployment has separate state
- Changes to dev don't affect prod
- Different resources despite same code

**Manual Approvals:**
- Both dev and prod require manual approval (free tier)
- Auto-approval requires HCP Terraform Premium + custom deployment groups

**Reusable Components:**
- Same IAM module used for both deployments
- Different inputs create different resources
- Module sourced from Terraform Registry

### 14. Clean Up

**Destroy Deployments via Configuration**

Terraform Stacks expects infrastructure destruction to be code-driven. 

1. **Edit `deployments.tfdeploy.hcl`** - Uncomment `destroy = true` in both deployments:

```hcl
deployment "development" {
  inputs = {
    aws_region     = "us-east-2"
    environment    = "dev"
    user_names     = ["alice", "bob"]
    aws_access_key = store.varset.aws_creds.AWS_ACCESS_KEY_ID
    aws_secret_key = store.varset.aws_creds.AWS_SECRET_ACCESS_KEY
  }
  destroy = true  # Uncommented
}

deployment "production" {
  inputs = {
    aws_region     = "us-east-2"
    environment    = "prod"
    user_names     = ["alice", "bob", "charlie"]
    aws_access_key = store.varset.aws_creds.AWS_ACCESS_KEY_ID
    aws_secret_key = store.varset.aws_creds.AWS_SECRET_ACCESS_KEY
  }
  destroy = true  # Uncommented
}
```

2. **Upload the updated configuration:**

```bash
terraform stacks configuration upload \
  -organization-name YOUR_ORG \
  -project-name lab-22-stacks \
  -stack-name lab-22-stacks
```

3. **Approve destroy plans in HCP Terraform UI:**
   - Go to your Stack → **Deployments** tab
   - You'll see destroy plans for both deployments
   - Click on **development** deployment → **Approve Plan**
   - Click on **production** deployment → **Approve Plan**
   - Wait for both destructions to complete

4. **Verify in AWS Console:**
   - Navigate to: **IAM** → **Users**
   - All created users should be deleted (dev-alice, dev-bob, prod-alice, prod-bob, prod-charlie)

**Delete the Stack (Optional):**

After deployments are destroyed, you can leave the empty Stack for future use (costs nothing) or delete it from the HCP Terraform UI if available in your version.

**Note:** HashiCorp expects Stacks to be long-running infrastructure. The `destroy = true` approach keeps all changes in version-controlled code, following Infrastructure as Code best practices.

---

## Key Takeaways

✅ **Stacks enable multi-environment deployments** from a single configuration

✅ **Each deployment is isolated** with its own state file

✅ **Orchestration rules** can auto-approve dev while protecting prod

✅ **Components use registry modules** for reliable CLI operations

✅ **Requires HCP Terraform** - cannot run purely locally

---

## Differences from Workspaces

| Feature | Workspaces | Stacks |
|---------|-----------|--------|
| State | Same backend, different keys | Separate per deployment |
| Configuration | Identical across environments | Can vary via inputs |
| Dependencies | Manual (run triggers) | Built-in orchestration |
| Scale | Individual management | Bulk operations |

---

## Troubleshooting

**Error: "Stack not found"**
- Make sure you ran `terraform stacks create` first
- Verify organization and project names are correct

**Error: "Missing .terraform-version file"**
- Ensure `.terraform-version` file exists in stack root
- File should contain exact version number matching your local Terraform CLI (no constraints like `~>`)
- Check with: `terraform version` then update file: `echo "1.x.x" > .terraform-version`

**Error: "Cannot resolve relative path"**
- This occurs with local modules (e.g., `./modules/users`)
- Solution: Use registry modules (as this lab does)

**Deployment stuck in planning:**
- Check AWS credentials are configured correctly
- Verify IAM permissions include `iam:CreateUser`, `iam:TagUser`

**Error: "No valid credential sources found" or "no EC2 IMDS role found":**
- **Cause 1:** Missing or incorrect `store` block in `deployments.tfdeploy.hcl`
  - **Fix:** Ensure `store` block references correct variable set name: `name = "AWS Credentials"`
  - Verify deployments pass credentials: `aws_access_key = store.varset.aws_creds.AWS_ACCESS_KEY_ID`
- **Cause 2:** Variable set NOT applied to entire project
  - **Fix:** Go to HCP Terraform → Settings → Variable sets → Select your AWS variable set → Verify "Applied to" shows "lab-22-stacks (project)"
- **Cause 3:** Variable set name mismatch
  - **Fix:** Store block `name` must exactly match your variable set name in HCP Terraform (case-sensitive)

---

## Extra Credit: 

### Use VCS

It might take some doing, but try to do this lab, but using VCS and your git-based repository!

### Using Local Modules with Registry

If you want to use your own custom modules with Stacks:

1. **Publish module to HCP Terraform Private Registry:**
   - Create Git repository with module
   - In HCP Terraform: **Registry** → **Publish** → **Module**
   - Connect to VCS repository
   - Tag a release (e.g., `v1.0.0`)

2. **Reference in component:**
   ```hcl
   component "iam_users" {
     source  = "app.terraform.io/YOUR-ORG/users/aws"
     version = "1.0.0"
     ...
   }
   ```

3. **Local validation will work:**
   ```bash
   terraform stacks init
   terraform stacks validate  # Now succeeds
   ```

**Note:** Local modules (relative paths) don't work reliably with `terraform stacks` CLI commands due to path resolution issues.

---

## Learn More

- **Stacks Documentation:** https://developer.hashicorp.com/terraform/language/stacks
- **Deploy a Stack Tutorial:** https://developer.hashicorp.com/terraform/tutorials/cloud/stacks
- **Stacks vs Workspaces:** https://developer.hashicorp.com/terraform/cloud-docs/stacks#stacks-vs-workspaces
- **AWS IAM Module:** https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest

---

**Note:** HCP Terraform and Terraform Cloud are the same product. "Terraform Cloud" was renamed to "HCP Terraform" in April 2024.
