# ⚙️ Lab 24 - Terraform Provider Caching

By default, Terraform downloads provider plugins into the .terraform directory in your working directory.

Over time, if you have a lot of projects, these plugins can take up a lot of space. At 200 to 600 MB per plugin download, you see what I mean. 

Enter in *provider caching*! This method stored a provider plugin once in a specific directory of your choice and it can be reused by all your other projects that require that same provider plugin. 

## Procedure

### Configure the .terraformrc File

First, change to your home directory:

`cd`

Then, check if a `.terraformrc` file already exists. It normally doesn't in a standard Terraform installation.

Create and edit the file:

`vim .terraformrc`

> Note: Use whichever editor you like best.

Add the following lines to the file:

```
plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true
```

This tells Terraform where to store provider plugins. 

Save the file and exit.

### Create the Cache Directory

By default, you should have the `.terraform.d` directory in your home directory. However, it will not contain plugin-cache... yet... Make it!

Change over to `terraform.d`

```
cd .terraform.d
```

Now, make the new directory:

```
mkdir plugin-cache
```

Verify that it is there with `ls`.

### Use Provider Caching!

Create a `main.tf` file in this lab's directory. Add the following:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.26"
    }
  }

  required_version = ">= 1.14.2"
}

provider "aws" {
  region = "us-east-2"  
}

resource "aws_iam_user" "test_user" {
  name = "user-${count.index}" 
  count = 3
  tags = {
    time_created = timestamp()    
    department = "OPS"
  }
}
```

Run `terraform init` to initialize the directory. 

If configured properly, the plugin will be stored in the cache directory and a symbolic link will be created to it from the .terraform directory within Terraform's working directory.

Check the plugins directory now:

`cd $HOME/.terraform.d/plugin-cache`

You should see the plugin there now. 

This plugin will be used for subsequent Terraform initializations in other projects. 

> Note: Other versions of the plugin will be downloaded separately. 

You will note that your working Terraform directory does have `.terraform/providers`, but this is linking to the cached directory via a symbolic link.

### Change it Back!

Let's undo our work. 

Return back to your home directory

`cd`

You can either modify or delete the `.terraformrc` file.

- To modify it, simply access it and delete the two lines that we added previously.
- To delete the file, type `rm .terraformrc`

However, you might want to keep it because it can be used to do many other configurations in Terraform. See [this link](https://developer.hashicorp.com/terraform/cli/config/config-file) for more.

Now, remove the `plugin-cache` directory. (that is, unless you want to keep caching!)

```
rm -r $HOME/.terraform.d/plugin-cache/
```

Now, everything should be back to normal. 

## Considerations

Caching is good, but it's not great. There are some things to consider when using provider caching including:

- **Concurrency Issues:** The built-in plugin cache is not entirely concurrency safe. Running multiple terraform init processes simultaneously can lead to conflicts and errors.
- **Manual Cleanup:** Terraform does not automatically delete old, unused provider versions from the cache directory. You must manually manage the cache directory over time to prevent it from growing excessively large.
- **CI/CD Optimization:** Caching providers in CI/CD pipelines can significantly reduce execution time and external dependencies.
- **Dependency Lock File:** The .terraform.lock.hcl file is crucial for ensuring consistent provider versions across different runs and systems. When using caching, ensure your lock file includes valid checksums for the target platform to avoid warnings. 

## Extra Credit

Did you know that the `terraform init` command will tell Terraform to look in several locations for plugins before accessing the working directory's `.terraform` location?

They include:

- terraform.d/plugins 
- /home/user/.terraform.d/plugins
- /home/user/.local/share/terraform/plugins
- /usr/local/share/terraform/plugins
- /usr/share/terraform/plugins

Any of these locations can be used to permanently store provider plugins.

---

Plus, you can call on provider plugins from other internal/external locations as well:

From local machine
```
  required_providers {
    abc-provider = {
	  source = "<hostname>/registry-name/abc-provider"
	  version - "x"
	}
  }
```
From local domain or web sources
```
  required_providers {
    abc-provider = {
	  source = "terraform.local/registry-name/abc-provider"
	  version - "x"
	}
  }
```
and... (may have to edit the .terraformrc file)
```
provider_installation {
  filesystem_mirror {
    path    = "/home/user/.terraform.d/plugins"
  }
  direct {
    exclude = ["terraform.local/*/*"]
  }
}
```

LOTS OF OPTIONS! These can be helpful in customized environments. 

> Note: More information here: https://developer.hashicorp.com/terraform/cli/config/config-file#explicit-installation-method-configuration