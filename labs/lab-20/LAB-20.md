# ⚙️ Lab 20 - Using Vault with Terraform CLI

**Estimated Time:** 10-15 minutes

## Objective

Learn how to integrate HashiCorp Vault with Terraform to securely manage and retrieve secrets.

## Prerequisites

- Terraform installed
- Terminal access
- VS Code or favorite IDE

---

## Introduction

HashiCorp Vault is a secrets management tool. It securely stores, controls, and tightly manages access to sensitive data like API keys, passwords, and certificates. This tool can be used to go beyond the sensitive data storage/retrieval methods we have discussed so far in this course. 

In this lab we will work with Vault in "Dev" mode, which is designed for testing and learning purposes. 

> Note: To learn more about Vault, check out my video course at [this link](https://learning.oreilly.com/course/hashicorp-certified-vault/9780138312923/). 

## Step 1: Install HashiCorp Vault

Install Vault based on your operating system:

**macOS:**
```bash
brew install vault
```

**Linux (Ubuntu/Debian):**

If you already setup the HashiCorp repository when you installed Terraform then you can simply use the command:

```
sudo apt install vault
```

otherwise, do the following:

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install vault
```

**Windows (using Chocolatey):**
```powershell
choco install vault
```

> Note: For more installation methods, see [this link](https://developer.hashicorp.com/vault/install).

---

Verify installation:
```bash
vault --version
```

---

## Step 2: Start Vault in Dev Mode

Open a terminal and start Vault in development mode:

```bash
vault server -dev -dev-root-token-id="root"
```

> **Important:** Keep this terminal window open. Vault is running in-memory and will be lost if you close it.

You should see output similar to:
```
WARNING! dev mode is enabled! In this mode, Vault runs entirely in-memory
and starts unsealed with a single unseal key...

You may need to set the following environment variables:

    $ export VAULT_ADDR='http://127.0.0.1:8200'

The unseal key and root token are displayed below...

Root Token: root
```

---

## Step 3: Configure Vault Environment

Open a **new terminal window** (keep Vault running in the first terminal).

Set the Vault address environment variable:

```bash
export VAULT_ADDR='http://127.0.0.1:8200'
```

Verify you can connect to Vault:

```bash
vault status
```

---

## Step 4: Login to Vault

Login using the root token:

```bash
vault login root
```

You should see:
```
Success! You are now authenticated.
```

---

## Step 5: Create Secrets in Vault

Create a secret with database credentials:

```bash
vault kv put secret/db-creds username=admin password=supersecret
```

Create another secret with API credentials:

```bash
vault kv put secret/api-keys api_key=12345-abcde-67890-fghij api_secret=secret-token-xyz
```

Verify the secrets were created:

```bash
vault kv get secret/db-creds
vault kv get secret/api-keys
```

---

## Step 6: Create Terraform Configuration Files

Create the following Terraform files in your working directory:

### `provider.tf`
```hcl
terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "~> 4.0"
    }
  }
}

provider "vault" {
  address = "http://127.0.0.1:8200"
  token   = "root"
}
```

### `main.tf`
```hcl
# Read database credentials from Vault
data "vault_generic_secret" "db_creds" {
  path = "secret/db-creds"
}

# Read API keys from Vault
data "vault_generic_secret" "api_keys" {
  path = "secret/api-keys"
}

# Example: Use the secret in a local file (for demonstration)
resource "local_file" "config" {
  filename = "${path.module}/app-config.txt"
  content  = <<-EOT
    Database Configuration:
    Username: ${data.vault_generic_secret.db_creds.data["username"]}
    
    API Configuration:
    API Key: ${data.vault_generic_secret.api_keys.data["api_key"]}
  EOT
}
```

### `outputs.tf`
```hcl
# Output the database username (non-sensitive)
output "db_username" {
  value       = data.vault_generic_secret.db_creds.data["username"]
  description = "Database username from Vault"
}

# Output the API key (marked as sensitive)
output "api_key" {
  value       = data.vault_generic_secret.api_keys.data["api_key"]
  description = "API key from Vault"
  sensitive   = true
}

# Show that we successfully retrieved secrets
output "secrets_retrieved" {
  value       = "Successfully retrieved secrets from Vault"
  description = "Confirmation of secrets retrieval"
}
```

---

## Step 7: Initialize and Apply Terraform

Initialize Terraform:

```bash
terraform init
```

Review the plan:

```bash
terraform plan
```

Apply the configuration:

```bash
terraform apply
```

Type `yes` when prompted.

---

## Step 8: Verify the Results

Check the outputs:

```bash
terraform output
```

You should see:
```
db_username = "admin"
api_key = <sensitive>
secrets_retrieved = "Successfully retrieved secrets from Vault"
```

View the sensitive output:

```bash
terraform output api_key
```

Check the generated configuration file:

```bash
cat app-config.txt
```

---

## Step 9: Cleanup

Destroy the Terraform resources:

```bash
terraform destroy
```

Type `yes` when prompted.

Stop the Vault dev server by pressing `Ctrl+C` in the terminal where it's running.

---

## Lab Summary

You have successfully:
1. ✅ Installed HashiCorp Vault
2. ✅ Started Vault in dev mode
3. ✅ Logged into Vault
4. ✅ Created secrets in Vault using the CLI
5. ✅ Retrieved secrets from Vault using Terraform
6. ✅ Used Vault secrets in Terraform resources

---

## Key Concepts

- **Vault Dev Mode:** In-memory server for testing (never use in production)
- **KV Secrets Engine:** Key-value store for static secrets
- **Vault Provider:** Terraform provider for reading/writing Vault data
- **Data Sources:** Read-only resources that fetch information from external sources

---

## Next Steps

- Watch the [HashiCorp Certified Vault Associate](https://learning.oreilly.com/course/hashicorp-certified-vault/9780138312923/) video course
- Explore Vault authentication methods (AppRole, AWS, etc.)
- Learn about dynamic secrets
- Implement Vault policies for access control
- Practice with Vault in production mode

---

## Troubleshooting

**Issue:** `Error: error reading from Vault: Error making API request`

**Solution:** Ensure Vault is running and `VAULT_ADDR` is set correctly.

---

**Issue:** `Permission denied`

**Solution:** Verify you're logged in with `vault login root`

---

**Issue:** `secret not found`

**Solution:** Verify the secret exists with `vault kv get secret/db-creds`
