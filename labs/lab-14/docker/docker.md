# Docker Lab with Terraform

## Prerequisites

- Debian 13 VM
- Terraform installed

## Lab Steps

### 1. Install Docker

Follow official Debian installation instructions:
https://docs.docker.com/engine/install/debian/

### 2. Configure User Permissions

```bash
sudo usermod -aG docker $USER
```

### 3. Reboot

```bash
sudo reboot
```

### 4. Deploy with Terraform

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Apply configuration
terraform apply
```

Type `yes` when prompted.

### 5. Test NGINX Container

Open browser and navigate to:
```
http://127.0.0.1:8000
```

You should see the NGINX welcome page.

### 6. Destroy Infrastructure

```bash
terraform destroy
```

Type `yes` when prompted.

---

## Extra Credit: Podman Alternative

Podman is a Docker alternative with native nftables support and rootless containers.

### Install Podman

```bash
sudo apt update
sudo apt install podman podman-compose
```

### Enable nftables (optional)

```bash
sudo mkdir -p /etc/containers/containers.conf.d
echo '[network]
firewall_driver="nftables"' | sudo tee /etc/containers/containers.conf.d/50-netavark-nftables.conf
```

### Run Container

```bash
# Pull image
podman pull nginx:latest

# Run container
podman run -d --name test-nginx -p 8000:80 nginx:latest

# Test in browser: http://127.0.0.1:8000

# Stop and remove
podman stop test-nginx
podman rm test-nginx
```

### Use Podman with Terraform

No code changes needed - just alias docker to podman:

```bash
alias docker=podman
```

Then run the same Terraform commands.