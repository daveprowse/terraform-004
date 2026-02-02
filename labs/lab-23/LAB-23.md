# ⚙️ Lab 23 - Advanced AWS Usage with Terraform

**⚠️ IMPORTANT: This lab will incur AWS costs!**

**Estimated costs:**
- **While running:** ~$0.012-0.015/hour (t2.micro instance)
- **While stopped:** ~$0.005/hour (Elastic IP not associated with running instance)
- **Remember to run `terraform destroy` when finished to avoid ongoing charges!**

---

**Objective:** Learn advanced Terraform techniques including instance state management, dynamic blocks, for_each loops, explicit dependencies, and AWS-specific resources.

**Time:** ~15 minutes

**Prerequisites:**
- Completed previous labs (basic Terraform knowledge)
- AWS account with credentials configured
- Terraform CLI 1.14.2+ installed
- AWS CLI installed and configured (for instance state management)

**Versions Used:**
- Terraform: 1.14.2+
- AWS Provider: 6.26+

---

## What You'll Learn

- **Instance State Management** - Start and stop EC2 instances without destroying them
- **For_each Loops** - Create multiple similar resources efficiently
- **Dynamic Blocks** - Flexible configuration based on input variables
- **Elastic IPs** - Assign static public IP addresses
- **Explicit Dependencies** - Control resource creation order with `depends_on`
- **CloudWatch Integration** - Monitor infrastructure with alarms
- **S3 Buckets** - Store logs and static assets

---

## Architecture Overview

You'll build a web server infrastructure with:
- 1 EC2 instance (Apache web server)
- 1 Elastic IP (static address)
- 1 Security group with dynamic ingress rules
- 2 IAM users (created after instance is ready)
- 1 S3 bucket (for access logs)
- 1 CloudWatch alarm (CPU monitoring)

**Key Feature:** The instance can be stopped/started without destroying resources, and IAM users are explicitly created only after the instance exists.

---

## Lab Files Structure

```
lab-23-advanced-aws/
├── variables.tf        # Input variables and validation
├── main.tf            # VPC, EC2, EIP, Security Group
├── iam.tf             # IAM users with depends_on
├── s3.tf              # S3 bucket for logs
├── cloudwatch.tf      # CloudWatch alarm
├── outputs.tf         # Output values
└── terraform.tfvars   # Variable values (create this)
```

---

## Step-by-Step Instructions

### 1. Review the Configuration Files

**variables.tf** - Defines input variables:

```hcl
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-2"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "instance_state" {
  description = "Desired state of the EC2 instance (running or stopped)"
  type        = string
  default     = "running"
  
  validation {
    condition     = contains(["running", "stopped"], var.instance_state)
    error_message = "Instance state must be 'running' or 'stopped'."
  }
}

variable "allowed_ssh_cidrs" {
  description = "CIDR blocks allowed to SSH (use for_each in security group)"
  type        = set(string)
  default     = ["0.0.0.0/0"]
}

variable "ingress_rules" {
  description = "Map of ingress rules (demonstrates dynamic blocks)"
  type = map(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    description = string
  }))
  default = {
    ssh = {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "SSH access"
    }
    http = {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTP access"
    }
    https = {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
      description = "HTTPS access"
    }
  }
}

variable "iam_users" {
  description = "Set of IAM usernames to create (demonstrates for_each)"
  type        = set(string)
  default     = ["app-deployer", "log-reader"]
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "enable_monitoring" {
  description = "Enable detailed CloudWatch monitoring"
  type        = bool
  default     = true
}
```

**main.tf** - Core infrastructure:

```hcl
terraform {
  required_version = ">= 1.14.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      ManagedBy   = "Terraform"
      Lab         = "Lab-23-Advanced-AWS"
    }
  }
}

# Data source: Get latest Amazon Linux 2023 AMI
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Data source: Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Security Group with DYNAMIC BLOCKS
resource "aws_security_group" "web_server" {
  name        = "${var.environment}-web-server-sg"
  description = "Security group for web server with dynamic ingress rules"
  vpc_id      = data.aws_vpc.default.id
  
  # Dynamic block creates ingress rules from variable
  dynamic "ingress" {
    for_each = var.ingress_rules
    
    content {
      from_port   = ingress.value.from_port
      to_port     = ingress.value.to_port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }
  
  tags = {
    Name = "${var.environment}-web-server-sg"
  }
}

# EC2 Instance
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type
  
  vpc_security_group_ids = [aws_security_group.web_server.id]
  
  monitoring = var.enable_monitoring
  
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from ${var.environment} environment!</h1>" > /var/www/html/index.html
              echo "<p>Instance ID: $(ec2-metadata --instance-id | cut -d ' ' -f 2)</p>" >> /var/www/html/index.html
              EOF
  
  tags = {
    Name        = "${var.environment}-web-server"
    Environment = var.environment
  }
  
  lifecycle {
    ignore_changes = [user_data]
  }
}

# Instance State Management using AWS CLI
resource "null_resource" "instance_state_manager" {
  triggers = {
    instance_id    = aws_instance.web_server.id
    desired_state  = var.instance_state
  }

  provisioner "local-exec" {
    command = var.instance_state == "stopped" ? "aws ec2 stop-instances --instance-ids ${aws_instance.web_server.id} --region ${var.aws_region}" : "aws ec2 start-instances --instance-ids ${aws_instance.web_server.id} --region ${var.aws_region}"
  }
}

# ELASTIC IP - Static public address
resource "aws_eip" "web_server" {
  domain = "vpc"
  
  tags = {
    Name        = "${var.environment}-web-server-eip"
    Environment = var.environment
  }
}

# EIP Association
resource "aws_eip_association" "web_server" {
  instance_id   = aws_instance.web_server.id
  allocation_id = aws_eip.web_server.id
  
  # Only associate if instance is running
  count = var.instance_state == "running" ? 1 : 0
}
```

**iam.tf** - IAM users with explicit dependencies:

```hcl
# IAM Users with EXPLICIT DEPENDS_ON
# These users are created AFTER the EC2 instance
# Use case: Users need instance to exist before they can deploy to it

resource "aws_iam_user" "app_users" {
  for_each = var.iam_users
  
  name = "${var.environment}-${each.value}"
  path = "/app-users/"
  
  tags = {
    Name        = "${var.environment}-${each.value}"
    Environment = var.environment
    Purpose     = "Application deployment and monitoring"
  }
  
  # Explicit dependency: Create users only AFTER instance exists
  depends_on = [aws_instance.web_server]
}

# IAM Policy for S3 access
resource "aws_iam_policy" "s3_logs_access" {
  name        = "${var.environment}-s3-logs-access"
  description = "Allow read access to log bucket"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.logs.arn,
          "${aws_s3_bucket.logs.arn}/*"
        ]
      }
    ]
  })
}

# Attach policy to users using FOR_EACH
resource "aws_iam_user_policy_attachment" "s3_logs_access" {
  for_each = aws_iam_user.app_users
  
  user       = each.value.name
  policy_arn = aws_iam_policy.s3_logs_access.arn
}
```

**s3.tf** - S3 bucket for logs:

```hcl
# S3 Bucket for application logs
resource "aws_s3_bucket" "logs" {
  bucket = "${var.environment}-web-server-logs-${data.aws_caller_identity.current.account_id}"
  
  tags = {
    Name        = "${var.environment}-logs"
    Environment = var.environment
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  versioning_configuration {
    status = "Enabled"
  }
}

# Lifecycle rule
resource "aws_s3_bucket_lifecycle_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  
  rule {
    id     = "delete-old-logs"
    status = "Enabled"
    
    filter {
      prefix = ""
    }
    
    expiration {
      days = 90
    }
    
    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

# Data source for account ID
data "aws_caller_identity" "current" {}
```

**cloudwatch.tf** - CloudWatch alarm:

```hcl
# CloudWatch Alarm for high CPU usage
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-web-server-high-cpu"
  alarm_description   = "Alert when CPU exceeds 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  
  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
  
  alarm_actions = []  # Add SNS topic ARN here for notifications
  
  tags = {
    Name        = "${var.environment}-high-cpu-alarm"
    Environment = var.environment
  }
  
  # Only create alarm if monitoring is enabled
  count = var.enable_monitoring ? 1 : 0
}
```

**outputs.tf** - Output important values:

```hcl
output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.web_server.id
}

output "instance_state" {
  description = "Current state of the EC2 instance"
  value       = aws_instance.web_server.instance_state
}

output "elastic_ip" {
  description = "Elastic IP address (static)"
  value       = aws_eip.web_server.public_ip
}

output "instance_private_ip" {
  description = "Private IP of the instance"
  value       = aws_instance.web_server.private_ip
}

output "web_url" {
  description = "URL to access the web server"
  value       = var.instance_state == "running" ? "http://${aws_eip.web_server.public_ip}" : "Instance is stopped"
}

output "iam_user_names" {
  description = "Names of created IAM users"
  value       = [for user in aws_iam_user.app_users : user.name]
}

output "iam_user_arns" {
  description = "ARNs of created IAM users"
  value       = [for user in aws_iam_user.app_users : user.arn]
}

output "s3_bucket_name" {
  description = "Name of the S3 logs bucket"
  value       = aws_s3_bucket.logs.id
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.web_server.id
}

output "cloudwatch_alarm_arn" {
  description = "ARN of CloudWatch CPU alarm"
  value       = var.enable_monitoring ? aws_cloudwatch_metric_alarm.high_cpu[0].arn : "Monitoring disabled"
}
```

### 2. Create terraform.tfvars File

Create a `terraform.tfvars` file to customize your deployment:

```hcl
aws_region     = "us-east-2"
environment    = "dev"
instance_state = "running"
instance_type  = "t2.micro"

# Customize IAM users
iam_users = ["app-deployer", "log-reader"]

# Customize ingress rules (optional - defaults are fine)
ingress_rules = {
  ssh = {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Restrict this in production!
    description = "SSH access"
  }
  http = {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP access"
  }
}
```

---

### 3. Initialize Terraform

Make sure you are working in the lab-23 directory.

```bash
terraform init
```

**Expected output:**
```
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 6.26"...
- Installing hashicorp/aws v6.x.x...

Terraform has been successfully initialized!
```

### 4. Plan the Infrastructure

```bash
terraform plan
```

**Observe the plan output:**
- **Dynamic blocks** create 2-3 security group rules from the `ingress_rules` map
- **for_each** creates 2 IAM users from the `iam_users` set
- **depends_on** shows IAM users will be created after the EC2 instance
- Elastic IP will be allocated and associated
- S3 bucket will be created with lifecycle rules
- CloudWatch alarm will monitor CPU

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted.

**Expected resources created:**
- 1 EC2 instance (running Apache)
- 1 Elastic IP (static address)
- 1 Security group (with 2-3 dynamic ingress rules)
- 2 IAM users (created after instance)
- 1 IAM policy
- 2 IAM policy attachments
- 1 S3 bucket (with versioning, lifecycle)
- 1 CloudWatch alarm

### 6. Verify the Deployment

**Check outputs:**
```bash
terraform output
```

You should see:
- `elastic_ip` - The static IP address
- `web_url` - URL to access the web server
- `iam_user_names` - List of created users
- `s3_bucket_name` - Log bucket name

**Test the web server:**
```bash
# Get the URL
WEB_URL=$(terraform output -raw web_url)

# Access it
curl $WEB_URL
```

You should see the "Hello from dev environment!" message.

**Note:** The web server is accessible because port 80 (HTTP) is enabled by default in the `ingress_rules` variable in `variables.tf`. The default configuration includes SSH (22), HTTP (80), and HTTPS (443) ports.

**Verify in AWS Console:**

1. **EC2** → Instances → See your instance running
2. **EC2** → Elastic IPs → See your EIP allocated
3. **IAM** → Users → See both users created
4. **S3** → Buckets → See your log bucket
5. **CloudWatch** → Alarms → See your CPU alarm

> Note: For fun, try the following command to check the cloudwatch alarm:
> ```
> aws cloudwatch describe-alarms --alarm-names "dev-web-server-high-cpu" --region="us-east-2"
> ```
> and this
> ```
> aws cloudwatch describe-alarms --query 'MetricAlarms[*].[AlarmName,StateValue]' --output table --region="us-east-2"
>```
> Like I said... FUN!

### 7. Stop the Instance (State Management)

**Edit `terraform.tfvars`** - Change instance state:

```hcl
instance_state = "stopped"
```

**Apply the change:**
```bash
terraform apply
```

**What happens:**
- `null_resource.instance_state_manager` triggers and runs AWS CLI command to stop the instance
- Instance is **stopped** (not destroyed)
- Elastic IP remains allocated (static)
- EIP association is removed (conditional count)
- IAM users, S3 bucket, and alarm remain unchanged
- Web server is inaccessible but infrastructure persists

**Note:** This uses AWS CLI via local-exec provisioner. Ensure your AWS credentials are configured locally (same credentials Terraform uses).

**Verify:**
```bash
# First, refresh Terraform state to see current AWS status
terraform apply -refresh-only

# Now check the instance state
terraform output instance_state
# Output: stopped

# Or check directly with AWS CLI
aws ec2 describe-instances --instance-ids $(terraform output -raw instance_id) --query 'Reservations[0].Instances[0].State.Name' --output text
```

**Important:** The `terraform output instance_state` command shows the state from Terraform's state file. Since we're using a local-exec provisioner to stop/start instances outside of Terraform's normal resource lifecycle, the state file doesn't automatically update. Running `terraform apply -refresh-only` updates the state file with the actual current state from AWS.

### 8. Restart the Instance

**Edit `terraform.tfvars`** - Change back to running:

```hcl
instance_state = "running"
```

**Apply:**
```bash
terraform apply
```

Instance restarts and EIP re-associates automatically!

### 9. Experiment with For_each

**Add another IAM user** - Edit `terraform.tfvars`:

```hcl
iam_users = ["app-deployer", "log-reader", "backup-operator"]
```

**Apply:**
```bash
terraform apply
```

Only the new user is created - existing users untouched. This demonstrates the power of `for_each` over `count`.

### 10. Modify Dynamic Ingress Rules

**Demonstrate the dynamic nature** - Edit `terraform.tfvars`:

The default configuration includes SSH (22), HTTP (80), and HTTPS (443). Let's modify the security group to use **completely different ports** to show how dynamic blocks truly work:

```hcl
ingress_rules = {
  dns = {
    from_port   = 53
    to_port     = 53
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "DNS access"
  }
  pop3 = {
    from_port   = 110
    to_port     = 110
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "POP3 access"
  }
  custom_app = {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Custom application"
  }
}
```

**Apply:**
```bash
terraform apply
```

**What happens:**
- Terraform **removes** the old SSH, HTTP, and HTTPS rules
- Terraform **adds** the new DNS, POP3, and custom app rules
- This demonstrates that dynamic blocks create rules based entirely on the input variable
- The security group is completely reconfigured without destroying/recreating it

**Note:** Your web server will no longer be accessible on port 80 after this change! This is intentional to demonstrate dynamic block behavior.

**Verify:**
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids $(terraform output -raw security_group_id) --query 'SecurityGroups[0].IpPermissions[*].[FromPort,ToPort]' --output table
```

You should see ports 53, 110, and 8080 instead of 22, 80, 443.

### 11. Review State File

```bash
terraform state list
```

**Observe:**
- `aws_iam_user.app_users["app-deployer"]` - for_each indexing
- `aws_iam_user.app_users["log-reader"]`
- `aws_security_group.web_server` - contains dynamic rules
- `aws_eip_association.web_server[0]` - conditional count

### 12. Clean Up

**Destroy all resources:**

```bash
terraform destroy
```

Type `yes` when prompted.

**What gets destroyed:**
- EC2 instance
- Elastic IP (released)
- Security group
- IAM users and policies
- S3 bucket (if empty - may need manual deletion)
- CloudWatch alarm

---

## Key Concepts Demonstrated

### 1. Instance State Management

```hcl
# Managed via null_resource with AWS CLI
resource "null_resource" "instance_state_manager" {
  triggers = {
    instance_id    = aws_instance.web_server.id
    desired_state  = var.instance_state
  }

  provisioner "local-exec" {
    command = var.instance_state == "stopped" ? 
      "aws ec2 stop-instances --instance-ids ${aws_instance.web_server.id} --region ${var.aws_region}" : 
      "aws ec2 start-instances --instance-ids ${aws_instance.web_server.id} --region ${var.aws_region}"
  }
}
```

**Use cases:**
- Stop instances during off-hours to save costs
- Maintain instance configuration without destroying
- Quick start/stop without full recreate
- Demonstrates using provisioners for infrastructure management

### 2. For_each Loops

```hcl
resource "aws_iam_user" "app_users" {
  for_each = var.iam_users  # Set of usernames
  name     = each.value
}
```

**Benefits over count:**
- Add/remove items without affecting others
- Resources indexed by meaningful keys
- No re-creation when list order changes

### 3. Dynamic Blocks

```hcl
dynamic "ingress" {
  for_each = var.ingress_rules
  content {
    from_port = ingress.value.from_port
    # ...
  }
}
```

**Use cases:**
- Variable number of similar blocks
- Flexible configuration from variables
- Cleaner than repeating identical blocks

### 4. Explicit Dependencies (depends_on)

```hcl
resource "aws_iam_user" "app_users" {
  # ...
  depends_on = [aws_instance.web_server]
}
```

**When to use:**
- Control creation order when Terraform can't infer it
- Ensure infrastructure exists before creating access users
- Handle timing issues between resources

### 5. Elastic IPs

```hcl
resource "aws_eip" "web_server" {
  domain = "vpc"
}
```

**Benefits:**
- Static IP address persists across instance stop/start
- Can be reassigned to different instances
- Essential for DNS configurations

### 6. Data Sources

```hcl
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  # ...
}
```

**Use cases:**
- Reference existing resources
- Get latest AMI automatically
- Avoid hardcoding values

### 7. Conditional Resources

```hcl
count = var.instance_state == "running" ? 1 : 0
```

**Use cases:**
- Optional resources based on variables
- Environment-specific resources
- Feature flags

---

## Troubleshooting

**Error: "InvalidInstanceID.NotFound"**
- Wait a moment after creating instance
- Terraform will retry automatically
- May need explicit `depends_on` if issues persist

**Error: S3 bucket already exists**
- Bucket names must be globally unique
- Change bucket name in configuration
- Use `${data.aws_caller_identity.current.account_id}` for uniqueness

**Instance won't stop/start**
- Ensure AWS CLI is installed and configured
- Verify AWS CLI uses same credentials as Terraform
- Check for protection settings in AWS console
- Verify `instance_state` variable value
- Review Terraform state: `terraform show`
- Note: State change via null_resource may take 30-60 seconds to complete

**IAM users not created**
- Verify `depends_on` is properly set
- Check IAM permissions for your AWS credentials
- Review plan output before apply

---

## Extra Credit Challenges

1. **Add SNS Topic** - Create SNS topic and subscribe CloudWatch alarm to it
2. **Multi-AZ Deployment** - Use `for_each` to create instances in multiple availability zones
3. **Auto Scaling Group** - Convert single instance to ASG with launch template
4. **Application Load Balancer** - Add ALB in front of instance(s)
5. **Parameter Store** - Store database connection strings in Systems Manager Parameter Store
6. **Secrets Manager** - Store database credentials securely
7. **VPC from Scratch** - Create custom VPC instead of using default
8. **Route53** - Add DNS record pointing to Elastic IP

---

## Key Takeaways

✅ **Instance state** can be managed without destroying infrastructure

✅ **for_each** provides flexible, maintainable resource creation

✅ **Dynamic blocks** enable variable configuration within resources

✅ **Elastic IPs** provide static addressing for dynamic infrastructure

✅ **depends_on** gives explicit control over resource creation order

✅ **CloudWatch** integrates easily for monitoring

✅ **S3 lifecycle rules** automate log retention

✅ **Conditional resources** with count enable flexible deployments

---

## Best Practices Applied

- ✅ Variables with validation
- ✅ Default tags via provider
- ✅ Data sources for dynamic values
- ✅ Outputs for important values
- ✅ Lifecycle rules for S3 cost management
- ✅ Security group restrictions
- ✅ IAM path organization
- ✅ Resource naming conventions
- ✅ Comments explaining complex logic

---

## Next Steps

- Explore modules to package this infrastructure
- Add remote backend for state management
- Implement workspaces for multiple environments
- Add Terraform Cloud integration
- Explore Terraform testing framework

---

**Time to complete:** ~15 minutes  
**AWS costs:** 
- **Running:** ~$0.012-0.015/hour (t2.micro + EIP associated)
- **Stopped:** ~$0.005/hour (EIP allocated but not associated)
**Remember:** Run `terraform destroy` when done to avoid charges!

