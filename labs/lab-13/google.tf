terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.16.0"
    }
  }
}

provider "google" {
  project = "project-1-<ID_number>" # Update with your project ID  
  region  = "us-east1"
}

resource "google_compute_network" "vpc_network" {
  name                    = "vpc-network-1"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "tf_subnetwork" {
  name          = "subnet-1"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-east1"
  network       = google_compute_network.vpc_network.id
}

resource "google_compute_instance" "google_vm_1" {
  name         = "google-vm-1"
  machine_type = "e2-micro"
  zone         = "us-east1-c"
  tags         = ["ssh"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-13" # Latest Debian
    }
  }

  metadata = {
    ssh-keys = "admin:${file("keys/google_key.pub")}"
  }

  metadata_startup_script = "sudo apt-get update"

  network_interface {
    subnetwork = google_compute_subnetwork.tf_subnetwork.id

    access_config {
      # Ephemeral public IP
    }
  }
}

resource "google_compute_firewall" "ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction     = "INGRESS"
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

output "public_ip" {
  value = google_compute_instance.google_vm_1.network_interface[0].access_config[0].nat_ip
}