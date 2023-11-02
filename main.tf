provider "google" {
  credentials = var.credential_file
  project     = var.project
  region      = var.region
  zone        = var.zone
}

variable "vm_names" {
  description = "xdxd"
  default = {
    "control-plane" = { name = "control-plane" },
    "worker-node-1" = { name = "worker-node-1" },
    "worker-node-2" = { name = "worker-node-2" }
  }

}

# locals {
#   vm_names = {
#     for v in var.vms : v.name => v.name
#   }
# }
### EXTERNAL IP ###
resource "google_compute_address" "app_dev_ip" {
  for_each = var.vm_names
  provider = google
  name     = "${each.value.name}-static-ip"
}

resource "google_compute_address" "app_dev_ip_internal" {
  for_each = var.vm_names
  provider = google
  name     = "${each.value.name}-internal-static-ip"
  address_type = "INTERNAL"

}

resource "google_compute_network" "default" {
  name                    = "k8s-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "k8s-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.default.id
}

resource "google_compute_instance" "dev" {

  for_each = var.vm_names

  name         = each.value.name
  machine_type = "e2-standard-2"
  zone         = var.zone
  tags         = ["http-server", "https-server", "ssh"]

  boot_disk {
    initialize_params {
      image = "projects/rocky-linux-cloud/global/images/rocky-linux-8-optimized-gcp-v20230912"
      size  = 20
      type  = "pd-balanced"
    }
  }
  network_interface {
    network    = google_compute_network.default.id
    subnetwork = google_compute_subnetwork.default.id
    access_config {
      nat_ip = google_compute_address.app_dev_ip[each.key].address
    }
  }
  #   metadata_startup_script = file("bootstrap.sh")
  timeouts {
    create = "20m"
    update = "2h"
    delete = "20m"
  }
}
