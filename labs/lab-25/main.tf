terraform {
  required_version = ">= 1.14.0"
  
  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = "~> 2.21"
    }
  }
}

provider "consul" {
  address = "localhost:8500"
}

# Read a key from Consul
data "consul_keys" "app_config" {
  key {
    name    = "welcome_message"
    path    = "app/config/welcome_message"
    default = "Hello from Consul!"
  }
}

# Use the Consul value in a local file
resource "local_file" "message" {
  filename = "${path.module}/welcome.txt"
  content  = data.consul_keys.app_config.var.welcome_message
}

# Output the value
output "message_from_consul" {
  description = "The message retrieved from Consul"
  value       = data.consul_keys.app_config.var.welcome_message
}
