provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
  credentials = file("${path.module}/../gcp-key.json")
}

resource "google_container_cluster" "primary" {
  name               = "gke-cluster"
  location           = var.zone
  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

variable "project_id" {
    default = "able-veld-462218-h4"
}
variable "region" { default = "us-central1" }
variable "zone" { default = "us-central1-a" }

