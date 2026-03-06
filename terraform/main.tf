terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 1. Enable Required APIs
resource "google_project_service" "compute_api" {
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

# 2. Create Custom VPC
resource "google_compute_network" "k8s_vpc" {
  name                    = "k8s-the-hard-way-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "k8s_subnet" {
  name          = "k8s-the-hard-way-subnet"
  ip_cidr_range = "10.240.0.0/24"
  region        = var.region
  network       = google_compute_network.k8s_vpc.id
}

# 3. Firewall Rules
# Allow SSH from anywhere
resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh-k8s-hardway"
  network = google_compute_network.k8s_vpc.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
}

# Allow internal communication between nodes
resource "google_compute_firewall" "allow_internal" {
  name    = "allow-internal-k8s-hardway"
  network = google_compute_network.k8s_vpc.name
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  source_ranges = ["10.240.0.0/24", "10.200.0.0/16"]
}

# 4. Reserve Static Internal IPs for Controllers
resource "google_compute_address" "controller_ips" {
  count        = 2
  name         = "controller-${count.index}-ip"
  subnetwork   = google_compute_subnetwork.k8s_subnet.id
  address_type = "INTERNAL"
  region       = var.region
}

# 5. Reserve Static Internal IPs for Workers
resource "google_compute_address" "worker_ips" {
  count        = 2
  name         = "worker-${count.index}-ip"
  subnetwork   = google_compute_subnetwork.k8s_subnet.id
  address_type = "INTERNAL"
  region       = var.region
}

# Define Zones explicitly to avoid function errors
locals {
  controller_zones = ["${var.region}-a", "${var.region}-b"]
  worker_zones     = ["${var.region}-a", "${var.region}-b"]
}

# 6. Create Controller Instances
resource "google_compute_instance" "controllers" {
  count        = 2
  name         = "controller-${count.index}"
  machine_type = "e2-standard-2"
  zone         = local.controller_zones[count.index]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.k8s_subnet.name
    network_ip = google_compute_address.controller_ips[count.index].address
    access_config {
      # Ephemeral external IP for SSH
    }
  }

  tags = ["k8s-controller"]
  
  # We removed the ssh-keys metadata to prevent file errors. 
  # We will add keys via gcloud after creation.
}

# 7. Create Worker Instances
resource "google_compute_instance" "workers" {
  count        = 2
  name         = "worker-${count.index}"
  machine_type = "e2-standard-2"
  zone         = local.worker_zones[count.index]

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 50
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.k8s_subnet.name
    network_ip = google_compute_address.worker_ips[count.index].address
    access_config {
      # Ephemeral external IP for SSH
    }
  }

  tags = ["k8s-worker"]
}