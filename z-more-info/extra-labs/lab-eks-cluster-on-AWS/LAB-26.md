# Lab-26: Terraform and EKS Cluster on AWS

**⚠️ IMPORTANT: This lab will incur AWS costs!**

**Estimated costs:** ~$0.10/hour for EKS control plane + ~$0.08/hour for 2x t3.medium nodes = **~$0.18/hour**

---

**Objective:** Create a basic Amazon EKS (Elastic Kubernetes Service) cluster using Terraform.

**Time:** ~15 minutes (cluster creation takes ~10 minutes)

**Prerequisites:**
- AWS account with credentials configured
- Terraform CLI 1.14.2+ installed
- AWS CLI installed (for verification)
- kubectl installed (optional - for cluster interaction)

**Note:** You can complete the lab without kubectl by using AWS CLI or the AWS Console to verify cluster status.

**Versions Used:**
- Terraform: 1.14.2+
- AWS Provider: 6.26+

---

## What You'll Build

- VPC with public and private subnets
- EKS cluster (control plane)
- EKS node group with 2 worker nodes (t3.medium)
- Required IAM roles and policies

---

## Lab Files

```
lab-26-eks/
├── variables.tf   # Input variables
├── main.tf        # VPC, EKS cluster, node group
└── outputs.tf     # Cluster information
```

---

## Step-by-Step Instructions

### 1. Review Configuration

**variables.tf** - Customize these values:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-2"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "lab26-eks-cluster"
}

variable "node_instance_type" {
  description = "EC2 instance type for EKS nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}
```

**main.tf** creates:
- VPC (10.0.0.0/16)
- 2 public subnets
- 2 private subnets
- Internet Gateway
- EKS cluster
- EKS node group (2 nodes)
- IAM roles and policies

---

### 2. Initialize Terraform

```bash
cd lab-26-eks
terraform init
```

---

### 3. Plan

```bash
terraform plan
```

**Expected resources:** ~20 resources will be created.

---

### 4. Apply

```bash
terraform apply
```

Type `yes` when prompted.

**Note:** Cluster creation takes approximately 10 minutes. Be patient.

---

### 5. Verify Cluster

**Get cluster information:**

```bash
terraform output
```

**Verify cluster status using AWS CLI:**

```bash
# Check cluster status
aws eks describe-cluster --region us-east-2 --name lab26-eks-cluster --query 'cluster.status'

# List node groups
aws eks list-nodegroups --region us-east-2 --cluster-name lab26-eks-cluster

# Check node group status
aws eks describe-nodegroup --region us-east-2 --cluster-name lab26-eks-cluster --nodegroup-name lab26-eks-cluster-nodes --query 'nodegroup.status'
```

Both should return `"ACTIVE"`.

**Verify via AWS Console:**
1. Go to AWS Console → EKS
2. Click on `lab26-eks-cluster`
3. Verify cluster status is "Active"
4. Click "Compute" tab → See node group with 2 nodes

---

**Optional: Verify with kubectl (if installed)**

If you have kubectl installed, configure it:

```bash
aws eks update-kubeconfig --region us-east-2 --name lab26-eks-cluster
```

**Verify nodes:**

```bash
kubectl get nodes
```

You should see 2 nodes in "Ready" status.

**Check cluster info:**

```bash
kubectl cluster-info
```

**Don't have kubectl?** See the "kubectl Installation" section at the end of this lab.

---

### 6. Deploy Test Application (Optional - Requires kubectl)

**Note:** This step requires kubectl. If you don't have it installed, skip to Step 7 or see the "kubectl Installation" section.

**Create a simple nginx deployment:**

```bash
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

**Get the LoadBalancer URL:**

```bash
kubectl get svc nginx
```

Wait a few minutes for the LoadBalancer to provision, then access the EXTERNAL-IP in your browser.

**Cleanup test app:**

```bash
kubectl delete svc nginx
kubectl delete deployment nginx
```

---

### 7. Clean Up

**Destroy all resources:**

```bash
terraform destroy
```

Type `yes` when prompted.

**Note:** Destruction takes ~5 minutes.

---

## What Was Created?

### Networking
- **VPC:** 10.0.0.0/16
- **Public Subnets:** 10.0.0.0/24, 10.0.1.0/24
- **Private Subnets:** 10.0.10.0/24, 10.0.11.0/24
- **Internet Gateway:** For public subnet internet access

### EKS Cluster
- **Control Plane:** Managed by AWS
- **Node Group:** 2x t3.medium instances in private subnets
- **Scaling:** Min 1, Desired 2, Max 3 nodes

### IAM
- **Cluster Role:** For EKS control plane
- **Node Role:** For worker nodes (EC2 instances)
- **Policies:** EKS, CNI, and ECR read-only access

---

## Troubleshooting

**Error: "cluster already exists"**
- Change `cluster_name` in variables.tf
- Or destroy the existing cluster first

**Cluster stuck in "Creating" state**
- Wait 10-15 minutes - this is normal
- Check AWS console for detailed status

**Nodes not ready**
- Check node group status: `terraform output node_group_status`
- Verify IAM policies are attached
- Check AWS console for node group events

**kubectl can't connect**
- Verify AWS CLI is configured: `aws sts get-caller-identity`
- Run the configure command: `aws eks update-kubeconfig --region us-east-2 --name lab26-eks-cluster`
- Check cluster endpoint: `terraform output cluster_endpoint`

---

## Key Takeaways

✅ EKS simplifies Kubernetes cluster management on AWS

✅ Terraform automates EKS cluster provisioning

✅ VPC configuration is critical for EKS networking

✅ IAM roles control cluster and node permissions

✅ Node groups provide managed EC2 instances for workloads

---

## Cost Management

**To avoid charges:**
- Run `terraform destroy` immediately after the lab
- EKS charges $0.10/hour for the control plane (even with no nodes)
- Node instances (t3.medium) cost ~$0.04/hour each

**Total cost if left running:**
- ~$4.32/day
- ~$130/month

**Always destroy when done!**

---

## kubectl Installation

If you want to interact with your EKS cluster, you'll need kubectl installed.

### Linux

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### macOS

**Option 1: Homebrew (Recommended)**

```bash
brew install kubectl

# Verify installation
kubectl version --client
```

**Option 2: Direct Download**

```bash
# Download kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"

# Make it executable
chmod +x kubectl

# Move to PATH
sudo mv kubectl /usr/local/bin/

# Verify installation
kubectl version --client
```

### Windows

**Option 1: Chocolatey**

```powershell
choco install kubernetes-cli
```

**Option 2: Direct Download**

1. Download from: https://kubernetes.io/docs/tasks/tools/install-kubectl-windows/
2. Add the binary to your PATH
3. Verify: `kubectl version --client`

**Option 3: Windows Subsystem for Linux (WSL)**

Use the Linux instructions above inside your WSL terminal.

### Verify kubectl Works with EKS

After installation, configure kubectl to use your EKS cluster:

```bash
aws eks update-kubeconfig --region us-east-2 --name lab26-eks-cluster

# Test connection
kubectl get nodes
```

---

**Time to complete:** ~15 minutes  
**AWS costs:** ~$0.18/hour while running  
**Remember:** Run `terraform destroy` when finished!
