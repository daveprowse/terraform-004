# IMPORTANT: Terraform Stacks require a "store" block to access variable sets
# Unlike regular workspaces, environment variables are NOT automatically available
# This store block references the "AWS Credentials" variable set you created in HCP Terraform
store "varset" "aws_creds" {
  name     = "AWS Credentials"  # Must match your variable set name exactly (case-sensitive)
  category = "env"
}

deployment "development" {
  inputs = {
    aws_region     = "us-east-2"
    environment    = "dev"
    user_names     = ["alice", "bob"]
    # Pass credentials from variable set to deployment
    aws_access_key = store.varset.aws_creds.AWS_ACCESS_KEY_ID
    aws_secret_key = store.varset.aws_creds.AWS_SECRET_ACCESS_KEY
  }
  #destroy = true
}

deployment "production" {
  inputs = {
    aws_region     = "us-east-2"
    environment    = "prod"
    user_names     = ["alice", "bob", "charlie"]
    # Pass credentials from variable set to deployment
    aws_access_key = store.varset.aws_creds.AWS_ACCESS_KEY_ID
    aws_secret_key = store.varset.aws_creds.AWS_SECRET_ACCESS_KEY
  }
  #destroy = true
}
