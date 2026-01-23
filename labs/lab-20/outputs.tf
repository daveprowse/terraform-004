# Output the database username (non-sensitive)
output "db_username" {
  value       = data.vault_generic_secret.db_creds.data["username"]
  description = "Database username from Vault"
  sensitive = true
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