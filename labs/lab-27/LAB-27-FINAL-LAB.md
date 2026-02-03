# ⚙️ Lab 27 - Final Terraform Lab: Terraform with AWS, Ansible, and Bash

*Rev. B - January 23, 2026*

[Dave Prowse](https://prowse.tech)

**UPDATED FOR:**
- Terraform 1.14.2+
- AWS Provider 6.26+
- S3 Bucket Module 4.2.2

This lab does the following:
- Creates an AWS S3 bucket (to act as the backend for our state files)
- Creates two Ubuntu VMs on AWS
- Uses Cloud-init to setup a new user and prepare the VMS. 
- Runs an Ansible playbook that installs an nginx web server to both VMs.
- Sets up a basic website for fun!
  
> Note: This lab is meant for demonstration purposes. In the field, I would organize it differently, add variables (many), and increase security to the Nth degree.

> Note: There are a **lot** of moving parts in this lab, and therefore a lot can go wrong. Be ready to troubleshoot! If you need to, contact me at my website (https://prowse.tech) or at my Discord server: (https://discord.com/invite/mggw8VGzUp).

## !!! IMPORTANT !!!

> The entire run is done within a bash script named automagic.sh. Be sure to analyze script files before running them!

> There is no solution directory. The entire lab is the solution.

> You will need to have Ansible installed on your system. More on that later in the lab.

## Analyze the Bash scripts and set permissions

- First, locate the automagic.sh and autodestroy.sh scripts and analyze them. 
  
> Remember: Be sure you understand what the scripts will do before executing them.
  
- Set the scripts' permissions to execute.
  
  `chmod +x {automagic.sh,autodestroy.sh}`

## Analyze the bucket, instances, and scripts directories

The entire process consists of two Terraform configurations:
- S3 bucket creation
- AWS infrastructure creation (instances and IAM users)
  
The first Terraform configuration creates the S3 bucket.
The bucket directory contains code for Terraform to create the bucket. This is then used by the second Terraform configuration as a backend for the state file.

You will see that the instances directory has a lot of .tf files. Analyze these and understand what each of them does. Essentially, this is where we have our AWS instances, security groups, and IAM users. The state file for this configuration will be stored within the previously created S3 bucket.

> Note: If you decide to change the AWS region(s), make sure that you utilize an Ubuntu AMI that exists in that region. Take note that this lab uses two AWS regions incorporating an alias.

The scripts directory contains a cloud-init script that will create a new user and run a couple of basic commands on the instances once they are created.

## Analyze the Ansible information

> Important! Ansible must be installed on your local system. See the following link for your distro: https://docs.ansible.com/ansible/latest/installation_guide/installation_distros.html#installing-ansible-on-specific-operating-systems

> If the Linux install via package manager does not work, use PIP: https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html

> You will need to have the `ansible` command set up within your PATH and your user will need to be able to run Ansible commands. That user account should also have administrative permissions (sudo or wheel).

Take a look at the files inside the Ansible directory.
- ansible.cfg is the main Ansible configuration file. It is called on by automagic.sh by exporting the config variable. It relies on the "hulk" account that was created by the cloud-init script.
- The inventory file is blank. This will be written to by the script, making use of the `terraform output` command (with options).
- The playbook is pretty simple. It installs nginx to the hosts, clones a git repository (forked version for reliability), and copies the files to the webserver so that the game will work. Feel free to modify the playbook as you see fit!

## Create SSH keys

- Go to the keys directory and build yourself an SSH key to use for this lab. I recommend using ed25519 and naming the key `ssh_key` so that it works with the lab properly.

  > Note: If you plan to use the optional Azure VM, you will need to use RSA-based SSH keys.

- Paste the public key into two places:
  - instances/key_deployer.tf: AWS key deployer (**both** ohio and virginia blocks)
  - scripts/hulk.yaml

> Note: If you change the name of the key, then specify that name in key_deployer.tf, variables.tf, ansible.cfg, and in automagic.sh

**Example key generation:**
```bash
cd keys
ssh-keygen -t ed25519 -f ssh_key -C "terraform-final-lab"
# Press Enter twice (no passphrase for lab purposes)
# The -f will build the key in the current directory. 
```

## Choose a Bucket Name and Bucket Key Name

**Bucket Name:**

Decide on a **globally unique** bucket name. S3 bucket names must be unique across all AWS accounts worldwide.

**Recommended format:** `terraform-<yourname>-<ddmmyyyy>`

**Examples:**
- `terraform-dave-23012026`
- `terraform-alice-23012026`

**Important:** Choose a unique name to avoid DNS conflicts and propagation issues!

Type your bucket name in the following places:
- `bucket/main.tf` - in the `bucket = ""` argument
- `instances/version.tf` - in the backend "s3" block `bucket = ""` argument

**Bucket Key:**

Decide on a key name (path within the bucket where the state file will be stored).

**Example:** `dir1/terraform.tfstate`

Type your key name in:
- `instances/version.tf` - in the backend "s3" block `key = ""` argument

**Example configuration:**
```hcl
# In bucket/main.tf:
bucket = "terraform-dave-23012026"

# In instances/version.tf:
backend "s3" {
  bucket = "terraform-dave-23012026"
  key    = "dir1/terraform.tfstate"
  region = "us-east-2"
}
```

## Applying the Infrastructure

Now we'll execute the Terraform run.

- Be sure that you are working in the `lab-27` directory in the terminal.
- Execute the automagic script.
  
  `./automagic.sh`
  
- Watch the magic sauce do its thing.

**What the script does:**
1. Creates the S3 bucket (waits 60 seconds for DNS propagation)
2. Initializes and applies the instances configuration
3. Generates the Ansible inventory from Terraform outputs
4. Waits for instances to initialize
5. Tests connectivity with ansible ping
6. Runs the playbook to install nginx and deploy the Asteroids game

**Expected runtime:** ~5-7 minutes

## Analyze what happened

- Review what occurred in the terminal including the Terraform information and the Ansible information.
- View the instances in the AWS console.
  > Note: Check both regions (us-east-2 Ohio and us-east-1 Virginia)!
- View the IAM users in the AWS console (7 users should be created).
- View the state file in the S3 bucket:
  - Go to S3 Console → Your bucket → You should see the terraform.tfstate file
  - View the contents of the state file:
    - Open/download it from the AWS console.
    - View it in the terminal: Example: 
      ```
      aws s3 cp s3://<bucket_name>>/dir1/terraform.tfstate - | jq '.'
      ```
    - Or use Terraform commands! (from the `instances` directory: `terraform state list`, `terraform show`, `terraform state show`, etc...)
- Attempt to connect to the webserver in your browser using **http** (not https):
  - `http://<public-ip-of-server-1>`
  - `http://<public-ip-of-server-2>`
  - You should see the Asteroids game!
  - > Note: use `terraform -chdir=instances output` to find out the public IPs again!
  - > Note: Many thanks to dmcinnes!
- Attempt to SSH into one of the instances and view the running nginx service:
  
  ```bash
  # Get the IP address
  terraform -chdir=instances output
  
  # SSH into the instance
  ssh -i "keys/ssh_key" hulk@<public-ip-address>

  # You could also use:
  ssh -i "keys/ssh_key" hulk@$(terraform -chdir=instances output -raw "public_ip_server_1")
  
  # Check nginx status
  systemctl status nginx

  # Look at the files
  
  cat hello.txt
  
  # Exit the instance
  exit
  ```

Do whatever other *analysis* you want!

---

## Terraform Graph

Use the `terraform graph` command to view Terraform dependencies. See the separate document, [LAB-27-terraform-graph](./LAB-27-terraform-graph.md) for details.

---

## Destroy the infrastructure

Once again, it's very important to destroy the infrastructure so that you are not billed any more than need be.

From the `lab-27` directory, use the autodestroy.sh script to destroy the infrastructure:

```bash
./autodestroy.sh
```

**If the script fails,** manually destroy both configurations:

```bash
# Destroy instances first (has dependencies on bucket)
terraform -chdir=instances destroy

# Then destroy the bucket
terraform -chdir=bucket destroy
```

Be sure that all infrastructure is terminated in the AWS console! This includes:
- **2 EC2 instances** (one in us-east-2, one in us-east-1)
- **7 IAM users** (Alice, Bob, Charlie, Denise, Erin, Frank, Darth)
- **1 S3 bucket** (with your chosen name)
- **2 Security groups** (one per region)
- **2 SSH key pairs** (one per region)

**!!! BE POSITIVE THAT ALL RESOURCES HAVE BEEN DESTROYED !!!**

---
## *Excellent! That was the final lab. Great work!*

If you have come this far, you get the trophy! 🏆
Continue on to the last lesson.

> Note: Sad, it's the last lab. Or [was it](//labs/lab-X/super-lab/LAB-X.md)?

---

## Troubleshooting

### Expected Warnings (Harmless)

**Warning: "Deprecated attribute" in S3 module**
```
Warning: Deprecated attribute
  on .terraform/modules/s3_bucket/main.tf line 608
```
- This warning comes from inside the S3 module code (not your configuration)
- It's harmless - the bucket will still be created successfully
- The module authors will fix this in a future version
- You can safely ignore this warning

### S3 Module Issues

**Error: "acl is no longer supported"**
- This is fixed in the updated version. The new module uses `object_ownership` instead.
- If you see this, verify you're using S3 module version 4.2.2

**Error: "bucket already exists"**
- S3 bucket names must be globally unique across all AWS accounts
- Choose a different bucket name with your name and date: `terraform-yourname-ddmmyyyy`
- Or destroy the existing bucket first

**Error: "requested bucket from us-east-2, actual location us-east-1"**
- This is a DNS propagation issue
- The script now waits 60 seconds instead of 5 seconds
- If you still see this, wait another minute and try again
- Verify `bucket/main.tf` has `region = "us-east-2"`
- Verify `instances/version.tf` backend block has `region = "us-east-2"`

**Error: "Unable to list objects in S3 bucket"**
- DNS propagation delay - wait 1-2 minutes after bucket creation
- Check bucket exists in AWS Console
- Verify bucket name matches in both files

### Provider Version Issues

**Error: "provider version constraint"**
- Run `terraform init -upgrade` to upgrade providers
- Verify version.tf has AWS provider `~> 6.26`

### Ansible Issues

**Error: "ansible command not found"**
- Install Ansible: `sudo apt install ansible` (Debian/Ubuntu)
- Or use pip: `pip install ansible --break-system-packages`
- Verify: `ansible --version`

**Error: "Permission denied (publickey)"**
- Verify SSH key is in keys/ directory named exactly "ssh_key"
- Check that public key is in **both** blocks in instances/key_deployer.tf
- Check that public key is in scripts/hulk.yaml
- Wait 2-3 minutes after instance creation for cloud-init to complete
- Verify key permissions: `chmod 600 keys/ssh_key`

**Error: "Host unreachable" during ansible ping**
- Wait longer - instances need time to fully boot
- Check security groups allow SSH (port 22) from your IP
- Verify instances are running in AWS Console

**Ansible playbook fails to install nginx**
- Check internet connectivity from instances
- Verify security groups allow outbound traffic
- SSH into instance and manually test: `sudo apt update`

### Instance Issues

**Error: "InvalidAMIID.NotFound"**
- AMIs are region-specific
- The lab uses specific Ubuntu 22.04 AMIs for us-east-2 and us-east-1
- If you change regions, update AMI IDs in instances/aws-instances.tf
- Find current Ubuntu AMIs: https://cloud-images.ubuntu.com/locator/ec2/

**Instances created but can't SSH**
- Check security group allows port 22 from your IP
- Wait 2-3 minutes for cloud-init to complete
- Verify you're using the correct private key
- Check you're SSHing as user "hulk" not "ubuntu"

**Website not accessible**
- Check security group allows port 80 from your IP
- Verify nginx is running: SSH in and run `systemctl status nginx`
- Check you're using **http** not https
- Get correct IP: `terraform -chdir=instances output`

### Script Issues

**automagic.sh fails during init**
- Bucket might not exist or have wrong name
- Check bucket name matches in both bucket/main.tf and instances/version.tf
- Try running commands manually instead of via script

**autodestroy.sh doesn't remove everything**
- Manually run: `terraform -chdir=instances destroy`
- Then run: `terraform -chdir=bucket destroy`
- Check AWS Console to verify everything is deleted
- If bucket won't delete, it might have objects - empty it first in Console

---

## What This Lab Teaches

**Terraform Concepts:**
- ✅ Remote state backend with S3
- ✅ Multiple providers (AWS in two regions)
- ✅ Provider aliases
- ✅ Using modules (S3 bucket module)
- ✅ Random resources for unique IDs
- ✅ Security groups with dynamic blocks
- ✅ IAM users with for_each
- ✅ Dependencies with depends_on
- ✅ Outputs and data passing

**AWS Services:**
- ✅ S3 buckets for state storage
- ✅ EC2 instances across multiple regions
- ✅ Security groups
- ✅ SSH key pairs
- ✅ IAM users
- ✅ Cloud-init for instance configuration

**Integration:**
- ✅ Terraform + Ansible workflow
- ✅ Using Terraform outputs in Ansible inventory
- ✅ Bash automation scripts
- ✅ Multi-tool orchestration

**Best Practices:**
- ✅ Remote state management
- ✅ Consistent naming conventions
- ✅ Tagging resources
- ✅ Automation with scripts
- ✅ Proper cleanup procedures

---