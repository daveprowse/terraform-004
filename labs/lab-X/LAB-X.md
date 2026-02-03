# Lab-X: AWS EC2 with ZORK Game and Documentation

- Software: Version 3.5

* Documentation: Rev. A - February 3, 2026*

[Dave Prowse](https://prowse.tech)

## Overview

Deploy two EC2 instances on AWS - one hosting the classic MIT-licensed ZORK I game and another providing documentation about how to use the game and ZORK characters.

**What You'll Build:**
- Two t3.micro EC2 instances (free tier eligible) with AWS Elastic IP addresses
  - ZORK I game server (web-based via iplayif.com Parchment CDN)
  - Character documentation server
- Auto-generated ED25519 SSH keys
- Automated deployment with progress monitoring

**Time:** 6-10 minutes total  
**Cost:** ~$0.72/day (DESTROY WHEN DONE!)

---

## Prerequisites

### 1. AWS Account
- Active AWS account with CLI configured
- Credentials in `~/.aws/credentials` or environment variables

### 2. Terraform
Version ~>1.14.2

```bash
terraform --version
```

**Don't have Terraform?** See [Installation Instructions](#installation-instructions) at end.

---

## Quick Start

### Step 1: Configure

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
student_name  = "YourName"
lab_name      = "lab-x"
aws_region    = "us-east-2"
instance_type = "t3.micro"
```

### Step 2: Deploy

```bash
chmod +x deploy.sh destroy.sh
./deploy.sh
```

**Script monitors deployment:**
1. Runs terraform init/plan/apply (~19s)
2. Waits for user-data completion (3-6 min)
3. Tests server readiness
4. Shows URLs when ready

### Step 3: Play ZORK!

After "SUCCESS" message:
- **ZORK:** `http://<zork-ip>`
- **Docs:** `http://<docs-ip>`

### Step 4: DESTROY!

Be sure to ***destroy*** when you are done so you are not charged any more than necessary. 

- With the bash script: `./destroy.sh`

    or  

- With the Terraform command: `terraform destroy`

---

## How it Works

**ZORK Server:**
1. Installs nginx
2. Downloads MIT-licensed ZORK I (zork1.z3)
3. Serves zork1.z3 as a static file via nginx
4. index.html loads iplayif.com in an iframe, passing zork1.z3 URL as the story parameter
5. iplayif.com's Parchment interpreter fetches and runs the game

---

## Analyze the Terraform Files

- Examine `main.tf`. Understand how the EC2 instances work in conjunction with the Elastic IPs, SSH keys, and so on. Also note how we are generating a ED25519 .pem key locally (resource "tls_private_key") and how that is being sent to AWS with the "aws_key_pair" deployer.
  > Note: Essentially it works like this: `tls_private_key` is a resource from the HashiCorp tls provider. Its actual job is simply generating a cryptographic key pair. It supports RSA, ECDSA, and ED25519 algorithms. That's it — it's a key generator. In main.tf it's being used purely for SSH. The chain is:
  > - `tls_private_key.ssh_key` generates an ED25519 key pair in memory during terraform apply
  > - `local_file.private_key` writes the private half to lab-x-key.pem on your local filesystem (mode 0600)
  > - `aws_key_pair.lab_key` uploads the public half to AWS
  >
  > Yeah! Terraform did all that!

- Examine `variables.tf` and understand the relationships between the instances and other resources and the variables blocks.
- Examine your `terraform.tfvars` file and understand the relationships between the variables blocks in `variables.tf` and the values here.
- Examine `outputs.tf` and understand how the SSH values work with the instances and their paths.

> Note: Analyze other files as well such as the Bash scripts and the .gitignore file. 

---

## Troubleshooting

### "Connection refused" after 10 minutes

```bash
# SSH and check logs
ssh -i lab-x-key.pem ubuntu@<zork-ip>
sudo tail -20 /var/log/cloud-init-output.log

# Should see "ZORK game server setup complete!"
# NOT "ERROR 404: Not Found"
```

### Test locally on instance

```bash
ssh -i lab-x-key.pem ubuntu@<zork-ip>
curl http://localhost
ls -la /var/www/html/
# Should see: index.html, zork1.z3, .setup-complete
```

---

## Playing ZORK

### Commands

**Movement:** `n`, `s`, `e`, `w`, `u`, `d`, `enter`, `exit`  
**Actions:** `look`, `examine <item>`, `take <item>`, `drop <item>`  
**Inventory:** `i` or `inventory`  
**Combat:** `attack <enemy> with <weapon>`  
**Save/Load:** `save`, `restore`, `restart`

### Tips

1. Map everything on paper
2. Save often before risky actions
3. Get lamp early - light is critical
4. Check docs server for character guides
5. Goal: Collect 19 treasures

---

## Cleanup

```bash
./destroy.sh
```

**Verify in AWS Console:**
- No EC2 instances
- No Elastic IPs
- No security groups

**Cost:** ~$0.72/day running

---

## Installation Instructions

### Terraform

**Ubuntu/Debian:**
```bash
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

**macOS:**
```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```

**Windows:**
```powershell
choco install terraform
```

### AWS CLI

```bash
aws configure
# Enter: Access Key, Secret, Region (us-east-2), Format (json)
```

---

## Credits

**Created by:** Dave Prowse (https://prowse.tech)  
**Version:** 3.5  
**Date:** February 2026

**ZORK I:** Marc Blank, Dave Lebling (1980), MIT Licensed by Microsoft (2025)  
**Parchment:** Dannii Willis, MIT License, hosted at iplayif.com

---

**Have fun exploring the Great Underground Empire!** 🏰
