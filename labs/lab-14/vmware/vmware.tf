# vSphere Provider Page: https://registry.terraform.io/providers/vmware/vsphere/latest/docs
# Learn more about vSphere: https://docs.vmware.com/en/VMware-vSphere/index.html 

# This is non-functional code used for demonstration purposes only.
# To make this code work, you would need a vSphere setup including at least one configured vCenter device and one ESXi server.
# You would also need a properly configured variables.tf file. I've added that as well as a terraform.tfvars, and added that to a .gitignore file.

terraform {
  required_providers {
    vsphere = {
      source  = "vmware/vsphere"
      version = "2.15.0"
    }
  }
}

provider "vsphere" {
  # In this implementation, it is recommended that you use environment variables for the username and password.
  user                 = var.vsphere_user
  password             = var.vsphere_password
  vsphere_server       = var.vsphere_server
  # In a production environment we would set the following to false.
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "datacenter" {
  name = "dc-01"
}

data "vsphere_datastore" "datastore" {
  name          = "datastore-01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_compute_cluster" "cluster" {
  name          = "cluster-01"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

data "vsphere_network" "network" {
  name          = "VM Network"
  datacenter_id = data.vsphere_datacenter.datacenter.id
}

resource "vsphere_virtual_machine" "vm" {
  name             = "debian-1"
  resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
  datastore_id     = data.vsphere_datastore.datastore.id
  num_cpus         = 1
  memory           = 1024
  guest_id         = "debian12_64Guest"
  network_interface {
    network_id = data.vsphere_network.network.id
  }
  disk {
    label = "disk0"
    size  = 20
  }
}

# ------
# To clone the VM from a cloud image in vSphere, do the following:

# 1. Download the image. For example, from: https://cloud.debian.org/images/cloud/
# 2. Use .qcow2 or .ova (convert to OVA if necessary).
# 3. Add the following code to the virtual machine resource
# clone {
#     template_uuid = data.vsphere_virtual_machine.template.id
#   }
# 4. Modify the guest ID:
# guest_id         = data.vsphere_virtual_machine.template.guest_id
# ------