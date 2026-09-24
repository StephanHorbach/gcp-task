terraform {
  required_version = ">= 1.6.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

data "google_compute_image" "ubuntu" {
  family  = var.image_family
  project = var.image_project
}

resource "google_compute_network" "vpc" {
  name                    = var.network_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_firewall" "ingress" {
  name          = "${var.network_name}-allow-ingress"
  network       = google_compute_network.vpc.id
  direction     = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
  target_tags   = var.network_tags

  dynamic "allow" {
    for_each = toset(var.allowed_ports)
    content {
      protocol = "tcp"
      ports    = [allow.value]
    }
  }
}

resource "google_compute_firewall" "egress" {
  name               = "${var.network_name}-allow-egress"
  network            = google_compute_network.vpc.id
  direction          = "EGRESS"
  destination_ranges = ["0.0.0.0/0"]
  target_tags        = var.network_tags

  allow {
    protocol = "all"
  }
}

resource "google_compute_instance" "webserver" {
  name         = var.instance_name
  machine_type = var.instance_type
  zone         = var.zone
  tags         = var.network_tags

  labels = {
    environment = var.environment
  }

  boot_disk {
    initialize_params {
      image = data.google_compute_image.ubuntu.self_link
    }
  }

  network_interface {
    network    = google_compute_network.vpc.id
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {}
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y apache2
    systemctl enable --now apache2
  EOT
}
