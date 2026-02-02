# Mini-Lab - Variables in the Terraform Cloud

In this mini-lab we'll work with Terraform variables and environmental variables within our workspace we created previously.

Spend a minute viewing the options for variables within your Workspace.

## Modify the Local Code

- Go to your code and change your region to a variable: 

    ```
    region = var.region
    ```

- Add a variable block for that region. Leave the value blank because we will define that at the Terraform Cloud.
- Comment out the access key and secret key variable blocks and their references in the provider block. Save the file.
- Comment out the credentials in `terraform.tfvars` and save the file. 

## Create Variables on the Cloud

- Return to the Terraform Cloud.
- Within your workspace, click "Variables".
- Click "+ Add variable".
- Enter the key (region) and the value (us-east-2).
- Click "Add variable".

    > Note: This variable does not need to be set to sensitive. We'll do that later.
    > Also, if you wanted to set variables to sensitive in your local code, you could simply add:
    > ```
    > sensitive = true
    > ```
    > to your variable block.

- Add two more variables. This time, select "Environment variable". 

  - Go to [this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs?product_intent=terraform#environment-variables) link for the proper AWS credentials naming conventions. 
    
    > Note: Feel free to simply paste those in. 

  -  Paste `AWS_ACCESS_KEY_ID` into the key field and the actual access key from terraform.tfvars into the value field. Mark it as sensitive. Add it.
  -  Paste `AWS_SECRET_ACCESS_KEY` into the key field and the actual secret key from terraform.tfvars into the value field. Mark it as sensitive. Add it.

## Login and Run Terraform

- Login to the Terraform Cloud with `terraform login`.
- Type `terraform init`. 
- Type `terraform apply` and watch the results!
- Verify in the AWS Console.
- View the triggered run in the Terraform Cloud > Workspace > Overview.

Take a look at the difference between Terraform variables and environment variables in the Terraform Cloud.

## Destroy!

Be sure to destroy the infrastructure.

```
terraform destroy
```

Check it in the Terraform Cloud and in the AWS Console.