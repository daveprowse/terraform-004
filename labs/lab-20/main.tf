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
