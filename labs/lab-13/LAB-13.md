# ⚙️ Lab-13 - Google Computer Engine VM Lab

In this lab we will create a virtual machine in the Google Compute cloud and SSH into it. 

> Warning! As with other cloud providers, you may be charged by Google. Be sure to destroy all infrastructure when you are done to limit cost. 

> **Cost:** As of the writing of this document (January, 2026) the "e2-micro" Google Compute instance costs in the neighborhood of 1 cent per hour. There are free tier regions including `us-central1`, `us-west1`, and `us-east1` that can include free hours - however, that can change at any time. We are using `us-east1` because it qualifies for free tier, but it is unknown what will happen in the future! Bottom line, be ready to incur a cost!

> Pricing Calculator: https://cloud.google.com/products/calculator

## Part 1

### Preparatory Work
As with any cloud-based provider, there are several steps we need to complete before we can get to the Terraform portion of the lab. Historically, Google Cloud has required more prep work than other cloud-based services such as AWS and Azure. 

If you are new to Google Cloud, spend some time familiarizing yourself with the service and the console. 

1. Create a Google Cloud account
    
    Do this at https://cloud.google.com/. You won't be able to run the lab without an account! 

    > Note: Chances are that you have a Google account already. That can be used as your Google Cloud account as well. Or, you might opt to create a wholly new account just for testing and educational purposes. 

    > IMPORTANT! Do not use a production account for any of the labs in this course!

2. Create a new project

    Make sure you are logged into Google Cloud, then access the console at https://console.cloud.google.com. 

    Create a new project from the main screen, or if you already have projects there, click on **Select a Project** and then **New Project**. Call it "project-1" and create it. 

3. Setup permissions

    Your account will need Compute Engine permissions to:
      - compute.instance.*
      - compute.firewalls.*

    > Note: If you only have one user (your account user), then that user is known as owner, and should have all permissions already enabled. However, if you want to work with another user, then go to the IAM section, click on the user account you want to use, and modify the permissions there.

4. Enable the Google Engine API for the project. If you can't find the location of this, try: 

    https://console.cloud.google.com/apis/library/compute.googleapis.com?

    > Note: You will need to have a billing account set up with Google Cloud. 

5. Install the gcloud CLI for your operating system:

    https://cloud.google.com/sdk/docs/install

6. Initialize and login with gcloud, and configure the system.
    
    Run the `gcloud init` command.

    You will be asked to login. Agree and login within the browser window that opens. Allow access for your account. 
    
    > Note: Make sure you are using the same account that you selected previously.

    Once authenticated, go back to the terminal. Select the project to use. Look for the one that is called "project-1-<ID>" and enter the number associated with that project.

    Then, if asked, say "no" to using a default Computer Region and Zone.

That's it. You should now be set up with Google Cloud and ready to continue to the next step!

### Review the Code and the Provider Documentation

Open up the provided google.tf file. You will see that it contains the code necessary to build an instance in the Google Cloud. 

Terraform will create a VPC and subnetwork, and then create a Debian VM with SSH support including an SSH firewall rule. It also outputs the public IP of the VM. 

Take 5 to 10 minutes analyzing the code and the naming conventions that Google Cloud uses. For example, an instance is known as "google_compute_instance", and a VPC is simply known as "google_compute_network". 

Take a few minutes to peruse the Google Provider: 

https://registry.terraform.io/providers/hashicorp/google/latest/docs

### Modify the Project Name and build SSH key pair

Locate the provider block in google.tf. Modify the project name so that it includes the proper ID after "project-1". 

Create a new directory: `mkdir keys`

Create a new SSH key pair with the `ssh-keygen` command. Name the key `google_key`. 

Verify that the keys are in the keys directory.

## Part 2

### Initialize, Validate, and Build the Infrastructure

Initialize the working directory. Make sure you are in lesson-10/google

`terraform init`

Validate your code:

`terraform validate`

If all is well, apply the infrastructure! When you apply, it should check the plan and ask you to confirm the creation of 4 resources.

`terraform apply`

**IMPORTANT!!** You might see an error if the Google credentials were not authenticated properly. If necessary, run the following command to load default credentials:

`gcloud auth application-default login`

**IMPORTANT!!** Click the "Select All" checkbox so that the Google Auth Library can access what it needs.

> Note: If the specified machine_type (e1-micro) is unavailable, consider using a different zone (for example, us-east1-b) or use a different machine type.

> For an entire list of machine families, see: https://cloud.google.com/compute/docs/machine-resource

Verify that the 4 resources were created successfully.

### SSH into the VM

You should be able to SSH in as the admin account. Use the outputted IP to SSH in! Example:

```
ssh -i "keys/google_key" admin@<ip_address>
```

In addition, you can do it from the Google Cloud Console:

- Go to the Google Cloud console. Go to your project.

- Access Computer Engine > VM Instances.

- Locate the VM. It should have an SSH option. Click it to SSH into the virtual machine. 

  - Try the browser-based option first.
  - Also, try the gcloud option. A typical gcloud ssh login one-liner might look like the following (change the project number and other values as need be):

      ```bash
      gcloud compute ssh --zone "us-east1-c" "google-vm-1" --project "project-1-387809"
      ```

If any of these work, then you have successfully built the infrastructure with Terraform!

Run the following command to see what OS we are running.

```
cat /etc/os-release
```

You should see it is Debian 13. 

Play around with the VM!

### Destroy the Infrastructure
As always, be sure to destroy the VM and supporting network infrastructure. In this case, we built 4 resources. Verify that all 4 are destroyed. 

`terraform destroy`

<Optional> To logout of the gcloud cli use the following commands:

```
gcloud auth revoke
```

and to remove the credentials:

```
gcloud auth application-default revoke
```

## Links:
- Google Provider: https://registry.terraform.io/providers/hashicorp/google/latest/docs
- Google Modules: https://registry.terraform.io/browse/modules?provider=google

---
## *Excellent!"*
---

