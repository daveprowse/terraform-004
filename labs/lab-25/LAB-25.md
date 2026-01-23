# ⚙️ Lab 25 - Using Consul with Terraform

**Objective:** Learn how to read configuration values from HashiCorp Consul using Terraform's Consul provider.

**Time:** ~8 minutes

**Prerequisites:**
- Docker installed (See end of document for installation instructions.)
- Terraform CLI 1.14.2+ installed
- Basic understanding of key-value stores

**Versions Used:**
- Terraform: 1.14.2+
- Consul Provider: 2.21+
- Consul: 1.19

---

## What is Consul?

**HashiCorp Consul** is a service networking solution that provides a full-featured control plane with service discovery, configuration, and segmentation capabilities. Think of it as a distributed system that helps your infrastructure services find and communicate with each other.

**Core capabilities:**
- **Service Discovery** - Automatically find and connect to services in your infrastructure
- **Health Checking** - Continuously monitor service health and availability
- **Key/Value Store** - Centralized configuration management and dynamic app config
- **Service Mesh** - Secure service-to-service communication with automatic TLS encryption
- **Multi-Datacenter** - Spans multiple datacenters and cloud providers

**Real-world use case:** Instead of hardcoding database endpoints in your application config files, store them in Consul. When the database endpoint changes, update it once in Consul and all applications automatically get the new value on their next deployment.

**For this lab:** We'll focus on Consul's **Key/Value Store** to demonstrate how Terraform can read dynamic configuration values from a centralized source.

---

## What You'll Learn

- Start a local Consul server using Docker
- Store configuration data in Consul
- Read Consul key-value data from Terraform
- Use Consul values in Terraform resources

---

## Lab Files Structure

```
lab-25-consul/
├── main.tf        # Terraform configuration
└── welcome.txt    # Generated file (after apply)
```

**Note:** No docker-compose file needed - we'll run Consul directly with `docker run`.

---

## Step-by-Step Instructions

### 1. Start Consul Server

**Start Consul using Docker:**

```bash
docker run -d \
  --name consul-server \
  -p 8500:8500 \
  -p 8600:8600 \
  hashicorp/consul:1.19 \
  agent -server -ui -bootstrap-expect=1 -client=0.0.0.0
```

**Command breakdown:**
- `-d` - Run in detached mode (background)
- `--name consul-server` - Name the container
- `-p 8500:8500` - Expose HTTP API and UI
- `-p 8600:8600` - Expose DNS port
- `agent -server -ui -bootstrap-expect=1 -client=0.0.0.0` - Consul server configuration

**Verify Consul is running:**

```bash
# Check container status
docker ps | grep consul

# Check Consul API
curl http://localhost:8500/v1/status/leader
```

You should see a response like `"127.0.0.1:8300"`

**Access Consul UI:**

Open your browser to: **http://localhost:8500**

You should see the Consul dashboard.

---

### 2. Store a Value in Consul

**Put a key-value pair in Consul using the CLI:**

```bash
# Using curl
curl -X PUT -d 'Welcome to Terraform and Consul integration!' http://localhost:8500/v1/kv/app/config/welcome_message
```

**Verify in Consul UI:**
1. Go to http://localhost:8500
2. Click **Key/Value** in the left sidebar
3. You should see `app/config/welcome_message` with your value

**Or verify via CLI:**

```bash
curl http://localhost:8500/v1/kv/app/config/welcome_message?raw
```

---

### 3. Review Terraform Configuration

**main.tf:**

```hcl
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
```

**Key concepts:**
- `data "consul_keys"` - Reads values from Consul
- `path` - The full path to the key in Consul's KV store
- `default` - Fallback value if key doesn't exist
- `data.consul_keys.app_config.var.welcome_message` - Access the value

---

### 4. Initialize Terraform

```bash
terraform init
```

**Expected output:**
```
Initializing provider plugins...
- Finding hashicorp/consul versions matching "~> 2.21"...
- Installing hashicorp/consul v2.x.x...

Terraform has been successfully initialized!
```

---

### 5. Plan and Apply

```bash
terraform plan
```

**Observe:**
- Terraform will read from Consul (`data.consul_keys.app_config`)
- Will create `welcome.txt` with the Consul value

**Apply:**

```bash
terraform apply
```

Type `yes` when prompted.

---

### 6. Verify the Result

**Check the output:**

```bash
terraform output message_from_consul
```

**Output:**
```
"Welcome to Terraform and Consul integration!"
```

**Check the generated file:**

```bash
cat welcome.txt
```

You should see:
```
Welcome to Terraform and Consul integration!
```

---

### 7. Update the Value in Consul

**Change the message in Consul:**

```bash
curl -X PUT -d 'Configuration updated dynamically!' http://localhost:8500/v1/kv/app/config/welcome_message
```

**Reapply Terraform:**

```bash
terraform apply
```

**What happens:**
- Terraform detects the Consul value changed
- Updates `welcome.txt` with the new value
- No infrastructure destroyed/recreated - just the file content updated

**Verify:**

```bash
cat welcome.txt
```

You should now see:
```
Configuration updated dynamically!
```

---

### 8. Clean Up

**Destroy Terraform resources:**

```bash
terraform destroy
```

Type `yes` when prompted. This removes `welcome.txt`.

**Stop and remove Consul container:**

```bash
docker stop consul-server
docker rm consul-server
```

**Remove Consul image (optional):**

```bash
docker rmi hashicorp/consul:1.19
```

---

## Key Concepts

### Data Source: consul_keys

```hcl
data "consul_keys" "app_config" {
  key {
    name    = "welcome_message"           # Local name in Terraform
    path    = "app/config/welcome_message" # Path in Consul KV store
    default = "Hello from Consul!"         # Fallback if key missing
  }
}
```

**Access the value:**
```hcl
data.consul_keys.app_config.var.welcome_message
```

### Why Use Consul with Terraform?

**Benefits:**
- **Dynamic Configuration** - Change values without modifying Terraform code
- **Centralized Configuration** - Single source of truth for multiple Terraform workspaces
- **Runtime Updates** - Update configuration without redeploying infrastructure
- **Shared State** - Multiple teams can read the same configuration values

**Use cases:**
- Environment-specific configuration (dev/staging/prod endpoints)
- Feature flags
- API keys and endpoints (non-sensitive)
- Application configuration
- Service discovery information

---

## Real-World Example

**Scenario:** Multiple Terraform workspaces need the same database endpoint.

**Consul stores:**
```
app/config/db_endpoint = "prod-db.example.com:5432"
```

**All workspaces read:**
```hcl
data "consul_keys" "config" {
  key {
    name = "db_endpoint"
    path = "app/config/db_endpoint"
  }
}

# Use in resources
resource "aws_instance" "app" {
  # ...
  user_data = <<-EOF
    #!/bin/bash
    export DB_ENDPOINT="${data.consul_keys.config.var.db_endpoint}"
  EOF
}
```

**Benefit:** Update Consul once, all workspaces get the new endpoint on next apply.

---

## Troubleshooting

**Error: "connection refused"**
- Verify Consul is running: `docker ps | grep consul`
- Check Consul is listening: `curl http://localhost:8500/v1/status/leader`
- Ensure port 8500 is not blocked

**Error: "Key not found"**
- Verify the key exists in Consul: `curl http://localhost:8500/v1/kv/app/config/welcome_message?raw`
- Check the path matches exactly (case-sensitive)
- If key is missing, Terraform will use the `default` value

**Consul UI not accessible**
- Verify port mapping: `docker port consul-server`
- Try `http://127.0.0.1:8500` instead of `localhost:8500`

**Permission denied when running docker commands**
- See "Docker Installation" section below for adding your user to the docker group

---

## Extra Credit

Want to learn more about Consul's powerful features?

**Explore the official Consul documentation:**
- **Getting Started Guide:** https://developer.hashicorp.com/consul/tutorials/get-started-vms
- **Key/Value Store Deep Dive:** https://developer.hashicorp.com/consul/docs/dynamic-app-config/kv
- **Service Discovery:** https://developer.hashicorp.com/consul/docs/concepts/service-discovery
- **Service Mesh (Consul Connect):** https://developer.hashicorp.com/consul/docs/connect

**Try these challenges:**
1. Store multiple configuration values in Consul and read them all in Terraform
2. Use Consul as a Terraform remote state backend
3. Set up service discovery for a multi-container application
4. Explore Consul's health checking capabilities
5. Integrate Consul with Vault for secrets management

---

## What's Next?

**Advanced Consul + Terraform patterns:**
- Write to Consul from Terraform (`consul_keys` resource)
- Use Consul for remote state backend
- Read service catalog information
- Integrate with Vault for secrets
- Use Consul Connect for service mesh

---

## Key Takeaways

✅ Consul provides a key-value store for dynamic configuration

✅ Terraform's `consul_keys` data source reads values at apply time

✅ Configuration can be updated in Consul without changing Terraform code

✅ Useful for sharing configuration across multiple Terraform workspaces

✅ Docker makes running Consul locally simple for development/testing

---

## Docker Installation

If you don't have Docker installed, follow these instructions for your operating system:

### Linux (Debian/Ubuntu)

```bash
# Update package index
sudo apt-get update

# Install Docker
sudo apt-get install -y docker.io

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker

# Verify installation
docker --version
```

**Add your user to the docker group (avoids using sudo):**

```bash
# Add your user to docker group
sudo usermod -aG docker $USER

# Log out and back in for the change to take effect
# Or run this to apply immediately in current session:
newgrp docker

# Verify you can run docker without sudo
docker ps
```

### macOS

**Install Docker Desktop:**

1. Download **Docker Desktop for Mac** from: https://www.docker.com/products/docker-desktop
2. Open the `.dmg` file and drag Docker to Applications
3. Launch Docker Desktop from Applications
4. Wait for Docker to start (whale icon in menu bar)

**Verify installation:**
```bash
docker --version
```

Docker Desktop automatically handles permissions on macOS - no group configuration needed.

### Windows

**Install Docker Desktop:**

1. Download **Docker Desktop for Windows** from: https://www.docker.com/products/docker-desktop
2. Run the installer
3. During installation, ensure "Use WSL 2 instead of Hyper-V" is selected (if available)
4. Restart your computer when prompted
5. Launch Docker Desktop

**Verify installation (PowerShell or CMD):**
```powershell
docker --version
```

Docker Desktop automatically handles permissions on Windows - no group configuration needed.

### Troubleshooting Docker Installation

**Linux: "Permission denied" when running docker commands**

This means your user is not in the docker group:

```bash
# Add user to docker group
sudo usermod -aG docker $USER

# Log out and back in, then verify
docker ps
```

**Linux: Docker service not starting**

```bash
# Check service status
sudo systemctl status docker

# Start the service
sudo systemctl start docker

# Enable auto-start on boot
sudo systemctl enable docker
```

**All platforms: Verify Docker is running**

```bash
# Check Docker info
docker info

# Run a test container
docker run hello-world
```

---

**Time to complete:** ~8 minutes  
**Cost:** Free (runs locally with Docker)  
**Remember:** Stop Consul when done: `docker stop consul-server`
