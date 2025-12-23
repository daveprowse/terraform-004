# ⚙️ Lab 05 - AWS Configuration with SSH and Outputs

Here you will build on the previous lab by adding proper SSH support. You'll also learn how to use outputs to have Terraform tell you information you need to know, such as the IP address and name of an instance.

# Procedure

This lab is a bit more in-depth, so go slow, and take it step-by-step. This time we'll be using a current Ubuntu image. If you get stuck, view the solution in the /solution directory. 

## Create a directory structure

Create two new directories: instances and keys.
For example: `mkdir {instances,keys}`

- Your main.tf file will go into the instances directory. This is the directory where you will run your Terraform commands.
- Your SSH keys will be placed in the keys directory.

## Create an SSH key pair

You will need openssh or another SSH tool installed. 

> Note: For this lab we will assume that you are using OpenSSH. There are links at the end of the lab that describe where to get OpenSSH and how to install it.

- Run the command `ssh-keygen` to create an SSH key pair.

  > Note: If you are using OpenSSH 9.5 or earlier, consider using ed25519 instead of the default RSA. 
  >
  > For example: `ssh-keygen -t ed25519`
  >
  > ed25519 is the default on OpenSSH version 9.6 or higher.

- Name the key "aws_key" and save the key to the "keys" directory. The path would be: `../keys/aws_key`. Alternatively, you can specify the path and key name with the `-f` option of the `ssh-keygen` command.)

## Build your Terraform files

- Make the following files within the instances directory:

  - version.tf
  - provider.tf
  - main.tf
  - outputs.tf

- In version.tf, use the standard terraform block code that you have used previously.
- In provider.tf, use the standard provider block code that you have used previously. Change the region to meet your geographical requirements.
- Copy the code from code-main.txt to your main.tf file. Analyze this file. Find the block named `resource "aws_key_pair"` and add your SSH public key where it says `public_key`
- Copy the code from `code-outputs.txt` to your `outputs.tf` file. Analyze this file. What information will Terraform supply you with when the terraform apply is complete? 
> IMPORTANT!! WATCH FOR ERRORS!!

## Initialize, validate, and apply your Terraform configuration

- Your working Terraform directory is /instances. 
- Use the commands you have learned to initialize, format, validate, plan, and finally, apply your configuration. 
- What information was outputted to you in the terminal?

> Note: If you lose the outputted information just type `terraform output` to see it again!

- Once the infrastructure has been built, view it within your AWS console.

## SSH into your new virtual machine.

Using the information that was outputted, SSH into your instance.

For example, you might do something similar to this:

```
ssh -i "../keys/aws_key" ubuntu@<ip_address>
```

> NOTE: If you were to look at the AWS console and view the SSH option, it would show "aws_key.pem" but the .pem extension will not work because we created a standard OpenSSH key pair, not an AWS key pair.

Make sure that you can access the system. Run commands on the remote system such as:

```
cat /etc/os-release
```

and

```
systemctl status apache2
```

(The second command should result in an error because apache2 is not installed yet. We'll do that in another lab!)

When done, exit out of the SSH session.

## Destroy the infrastructure

Use the appropriate command to destroy the infrastructure. BE SURE OF IT! Check in the AWS console.

---
## ♥️🖥 *As always, great work!* 🖥♥️
---

## OpenSSH Downloads

You can get OpenSSH in a variety of ways:

Main website: https://www.openssh.org/

**Windows**

To install OpenSSH on Windows 11 (Client or Server), go to: Settings > Apps > Optional features, click "Add a feature", search for "OpenSSH," and install either the Client, Server, or both. (You will only need the client for this lab.) 

Then ensure the Server service (sshd) is set to "Automatic" in the Services app (services.msc) and started, and allow port 22 through the firewall if using the server. 

**macOS**

OpenSSH is normally pre-installed on macOS, so there is no need for a separate installation. However, you can install it with HomeBrew if you wish:

```
brew install openssh
```

**Linux**

Just about every flavor of Linux makes OpenSSH accessible. For example:

- Ubuntu: `sudo apt install openssh-client`
  - or `openssh-server` for the both.
- Fedora: `sudo dnf install openssh-clients`
  - or: just `openssh`
- Arch: `sudo pacman -S openssh`

**USE IT!!**

