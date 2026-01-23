# READ THIS!
!!! This lab WILL cost $$$ money !!! 
There are many resources. If you don't want to incur cost, simply watch the corresponding video.

**UPDATED FOR:**
- Terraform 1.14.2+
- AWS Provider 6.26+
- S3 Bucket Module 4.2.2

To make the lab function you will need to do the following:
- Choose a bucket name and enter it in bucket/main.tf and in instances/version.tf
- Create an SSH key. Place it in the keys directory as "ssh_key".
- Reference it in instances/key_deployer.tf and scripts/hulk.yaml.
- Define any other variables not currently defined.
- Set the execute permission on the automagic.sh script and run it!
- !! IMPORTANT!! Make sure that you destroy everything when done. There is a script for that. Or, you could run a `terraform destroy` in both the instances directory and the bucket directory.

This has been the TLDR for the [LAB-27-FINAL-LAB](./LAB-27-FINAL-LAB.md) document. For detailed instructions, read that document!

Enjoy!

Dave Prowse
https://prowse.tech
