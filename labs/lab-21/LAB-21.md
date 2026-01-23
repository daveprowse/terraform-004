# ⚙️ Lab 21 - Using HCP Vault with Terraform Cloud

## Prerequisites
- Terraform 1.14.2 installed
- HashiCorp Cloud Platform (HCP) account
- Terraform Cloud account
- AWS account with valid credentials
- AWS CLI configured

## Overview

This lab demonstrates how to use HCP Vault (HashiCorp's managed Vault service) to securely store AWS credentials and retrieve them from Terraform Cloud to provision infrastructure.

‼️**WARNING!**‼️ *This lab will require you to send your AWS secret key over the Internet to the Vault Cluster*. If you are not comfortable doing this, stop, and simply watch the video.

## Part 1: Set Up HCP Vault Cluster

### Create HCP Account

1. Navigate to: https://portal.cloud.hashicorp.com/sign-up
2. Sign up with email or GitHub. 
    > Note: I recommend using the same account and password you used when signing up for the Terraform Cloud account.
3. Complete email verification
4. Log in to HCP Portal

### Create HCP Vault Cluster

1. From HCP Portal dashboard, go to **Vault Dedicated**, and click **Create Vault cluster**. (This will be a new, complete cluster, *not* created from a template.)
2. Configure cluster settings:
   - **Cluster name**: `vault-demo-cluster`
   - **Tier**: Select **Development** (free tier)
   - **Cloud provider**: AWS
   - **Region**: us-east-2 (or your preferred region)
   - **Network ID**: Select and note a name, for example, `vault-1`.
   - Leave any other networking information as the default.
3. Click **Create cluster**
4. Wait 5-10 minutes for cluster to provision

---

‼️**IMPORTANT**‼️ As of the writing of this lab, the cost of this type of Vault cluster is $0.617/hour (61 cents per hour). Keep this in mind, the lab can incur that charge! If you do not want this, do not create the cluster and simply watch the video. 

However, also as of the writing of this lab, new HCP organizations/accounts are granted $500 in trial credits across HCP products. See this [Link](https://developer.hashicorp.com/hcp/docs/hcp/admin/billing) for details.

---

### Access HCP Vault Cluster

1. Once cluster status is **Running**, click on the cluster name (if it doesn't automatically display).
2. Copy the **Public cluster URL** (format: `https://vault-demo-cluster-public-vault-xxxxxxxx.hashicorp.cloud:8200`) to a safe location.
3. Click **Generate token** to create an admin token
4. Copy the admin token (you'll need this for Terraform)

**Note:** Save both the cluster URL and admin token securely.

### Access Vault UI

1. Click **Launch web UI** button. That should take you to the public vault. If not, you can open a new tab and paste the public URL you saved previously.
2. Sign in using the admin token
3. You should see the Vault web interface

## Part 2: Store AWS Credentials in HCP Vault

### Enable KV Secrets Engine (if not already enabled)

1. In Vault UI, click **Secrets** in left sidebar
2. If KV is not present, click **Enable new engine** → **KV** → leave the default settings → **Enable Engine**

### Store AWS Credentials

**Option A: Using Vault UI**

1. From Secrets Engines, click on **kv/** 
2. Click **Create secret**
3. Set **Path**: `aws`
4. Add secret data:
   - Key: `access_key` | Value: `YOUR_AWS_ACCESS_KEY_ID`
   - Key: `secret_key` | Value: `YOUR_AWS_SECRET_ACCESS_KEY`

    > Note: Again, if you are not comfortable with putting your secret key in the Vault on the Internet, then do not. Another option is to create a new AWS access key for your test IAM user and use that access key solely for this lab, and deleting it when done.

5. Click **Save**

**Option B: Using Vault CLI**

First, configure Vault CLI to connect to HCP Vault:

```bash
export VAULT_ADDR='https://vault-cluster-public-vault-xxxxxxxx.hashicorp.cloud:8200'
export VAULT_TOKEN='hvs.YOUR_ADMIN_TOKEN'
export VAULT_NAMESPACE='admin'
```

Then store credentials:

```bash
vault kv put kv/aws \
  access_key="YOUR_AWS_ACCESS_KEY_ID" \
  secret_key="YOUR_AWS_SECRET_ACCESS_KEY"
```

### 7. Verify Credentials Stored

**Using Vault UI:**
1. Navigate to **Secrets Engines > kv/** > **aws**
2. Verify both keys are present

**Using Vault CLI:**

```bash
vault kv get kv/aws
```

## Part 3: Configure Terraform Cloud

### Create Terraform Cloud Organization

> Note: Only do this if you didn't in a previous lab.

1. Navigate to: https://app.terraform.io/
2. Click **Create organization**
3. Enter organization name (e.g., `your-company`)
4. Click **Create organization**
5. Create an organization.

### Create Workspace

1. Click **New workspace**
2. Select **CLI-driven workflow**
3. Enter workspace name: `hcp-vault-demo`
4. Click **Create workspace**

### Set Workspace Variables

In your workspace, navigate to **Variables** tab:

**Add Terraform Variables:**
- `vault_address` = `https://vault-cluster-public-vault-xxxxxxxx.hashicorp.cloud:8200` (your cluster URL)
- `vault_token` (mark as **sensitive**) = `hvs.YOUR_ADMIN_TOKEN`
- `vault_namespace` = `admin`

**Note:** The namespace for HCP Vault is always `admin`.

## Part 4: Configure Terraform Files

### Update main.tf

Edit `main.tf` and replace placeholders:

```hcl
terraform {
  cloud {
    organization = "your-company"  # Your TFC org name
    
    workspaces {
      name = "hcp-vault-demo"
    }
  }
  # ... rest of configuration
}
```

> Note: You can find this information in the workspace Overview.

### Authenticate to Terraform Cloud

```bash
terraform login
```

Follow prompts to create and paste API token. (Save the token in your file with the rest of your info.)

## Part 5: Deploy Infrastructure

### Initialize Terraform

```bash
terraform init
```

You should see: `Terraform Cloud has been successfully initialized!`

### Validate Configuration

```bash
terraform validate
```

### Plan Deployment

```bash
terraform plan
```

> Note: This could take a couple of minutes. Be patient, even if nothing appears to happen in the terminal.

Review the plan. Terraform Cloud will:
1. Authenticate to HCP Vault using the token
2. Read AWS credentials from `kv/aws` path
3. Use credentials to plan EC2 instance creation

You might also choose to review the plan in the Terraform Cloud within your workspace under **Runs**.

### Apply Configuration

```bash
terraform apply
```

Type `yes` when prompted.

> Note: Again, this may take a few minutes. 

### Verify Instance in AWS Console

1. Navigate to EC2: https://console.aws.amazon.com/ec2/
2. Find instance with tag `Name = HCP-Vault-TFC-Demo`
3. Verify instance is running
4. Note the public IP address (also shown in Terraform output)

## Part 6: Verify Security

### Check Terraform Cloud Logs

1. In Terraform Cloud, view the latest run
2. Click on **Plan** or **Apply** phase
3. Verify that AWS credentials are **not** visible in *logs*
4. Confirm that Vault connection was successful

> Note: You will be able to see your keys in the state file. This is normal with Terraform Cloud. However, to make this more secure, use the AWS Secrets Engine to provide dynamic credentials. More at the end of this lab.

### Verify State File Security

1. In workspace, click **States** tab
2. Click on latest state
3. Download and inspect state file (optional)
4. AWS credentials should be present in state (encrypted at rest in TFC)

**Note:** Terraform state files contain sensitive data. Terraform Cloud encrypts state at rest using AES-256.

## Part 7: Clean Up

### Destroy Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted.

### Delete Secrets from HCP Vault

**Using Vault UI:**
1. Navigate to **kv/** 
2. Click the three dots drop-down menu and **Permanently Delete** the entire aws secret.
3. Confirm deletion

**Using Vault CLI:**

```bash
vault kv delete secret/aws
```

### Delete HCP Vault Cluster

**Note:** Development tier clusters are free but count toward your resource limits.

1. In HCP Portal, navigate to your Vault cluster
2. Click **Manage** → **Delete cluster**
3. Type **DELETE** to delete the cluster. This should now show as "Disbaled" and can take several minutes to be completely removed. Press `F5` to refresh and verify that it is deleting. YOU DON"T WANT TO BE CHARGED ANY MORE THAN NECESSARY! SO CHECK IT!

### (Optional) Delete Terraform Cloud Workspace

1. Navigate to workspace settings
2. Click **Destruction and Deletion**
3. Queue destroy plan (if not already done)
4. Click **Delete workspace**
5. Type workspace name to confirm

## 🏆 GREAT WORK! THAT'S THE END OF THE LAB!

---

## Key Concepts

### HCP Vault
- **Managed Service**: HashiCorp operates and maintains Vault infrastructure
- **Public Cluster URL**: Accessible over the internet with TLS encryption
- **Admin Namespace**: HCP Vault uses `admin` namespace by default
- **Development Tier**: Free tier suitable for testing (not production)

### Integration Benefits
- **No Local Vault**: No need to run Vault server locally
- **Centralized Secrets**: Single source of truth for credentials
- **Audit Logging**: HCP Vault provides built-in audit logs
- **High Availability**: HCP Vault clusters are automatically HA

### Security Features
- **Encrypted Transit**: All communication uses TLS
- **Encrypted Storage**: Secrets encrypted at rest in HCP Vault
- **Encrypted State**: Terraform Cloud encrypts state files at rest
- **Token Expiration**: Admin tokens can be configured to expire
- **Audit Trail**: Both HCP Vault and Terraform Cloud provide audit logs

## Production Considerations

### Authentication
For production, use **Vault Dynamic Provider Credentials** instead of static tokens:
- Terraform Cloud authenticates to Vault using OIDC (OpenID Connect)
- No long-lived tokens required
- Automatic token rotation
- See: https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials/vault-configuration

### Vault Tiers
- **Development**: Free, single node, no SLA (testing only)
- **Starter**: Production-ready, HA, SLA included
- **Standard**: Enhanced performance and features
- **Plus**: Enterprise features

### AWS Dynamic Secrets
For production, use Vault's AWS Secrets Engine to generate dynamic credentials:
- Short-lived AWS credentials (auto-expire)
- No static credentials stored
- Automatic rotation
- See: https://developer.hashicorp.com/vault/docs/secrets/aws

### Namespace Strategy
- Use separate Vault namespaces for different teams/environments
- Apply policies for least-privilege access
- Consider using Vault AppRole for service authentication

## Troubleshooting

### Cannot Connect to HCP Vault
- Verify cluster is in **Running** state
- Check `vault_address` includes full URL with port `:8200`
- Ensure `vault_namespace` is set to `admin`
- Verify admin token is valid (check expiration)

### Terraform Cannot Read Secrets
- Verify KV v2 engine is enabled at `secret/` path
- Check secret exists at exact path: `secret/aws`
- Ensure keys are named `access_key` and `secret_key`
- Verify token has permissions to read secrets

### AWS Authentication Fails
- Verify AWS credentials stored in Vault are valid
- Test credentials using AWS CLI: `aws sts get-caller-identity`
- Check for typos in access key or secret key
- Ensure credentials have permissions to create EC2 instances

## AWS Secrets Engine

Note that State files ARE encrypted at rest using AES-256
✅ Access controlled by workspace permissions
✅ Audit logs track who viewed state
✅ TLS encrypted in transit
✅ Role-based access control limits who can view state

That being said, to use the **AWS Secrets Engine** for more secure, dynamic credentials, you will have to enable that engine in Vault, and then reference it from the Terraform code. Example: 

```hcl
# Vault dynamically creates AWS credentials
data "vault_aws_access_credentials" "creds" {
  backend = "aws"
  role    = "deploy-role"
  ttl     = "1h"  # Auto-expires
}

provider "aws" {
  region     = "us-east-2"
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}
```

> Note: You may have heard of OpenTofu. This is a forked alternative of Terraform. As of the writing of this lab version 1.7 of OpenTofu offers client-side state encryption where *you* provide the encryption keys instead of relying on someone else's keys. 

## Learn More

- My Vault video course: https://learning.oreilly.com/course/hashicorp-certified-vault/9780138312923/
- HCP Vault Documentation: https://developer.hashicorp.com/hcp/docs/vault
- Terraform Cloud Documentation: https://developer.hashicorp.com/terraform/cloud-docs
- Vault Provider: https://registry.terraform.io/providers/hashicorp/vault/latest/docs
- HCP Vault Pricing: https://cloud.hashicorp.com/products/vault/pricing
- Dynamic Credentials: https://developer.hashicorp.com/terraform/cloud-docs/dynamic-provider-credentials
