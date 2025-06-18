terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}

# Terraform configuration
# This will configure the Google Cloud provider
# The provider will be used to create resources in the Google Cloud platform
# The provider will be configured with the project ID, region, and zone
# The project ID is the ID of the project in the Google Cloud platform
# The region is the region in the Google Cloud platform
# The zone is the zone in the Google Cloud platform
provider "google" {
  project     = var.project_id
  region      = var.region
  zone        = var.zone
}

# Create a GKE cluster
# This will create a GKE cluster with 2 nodes
# The cluster will be named "gke-cluster"
# The cluster will be created in the zone "us-central1-a"
# The cluster will have 2 nodes
# The nodes will be of type "e2-medium"
# The nodes will have the oauth scopes "https://www.googleapis.com/auth/cloud-platform"
# The cluster will have the deletion protection disabled
resource "google_container_cluster" "primary" {
  name               = "gke-cluster"
  location           = var.zone
  initial_node_count = 2
  deletion_protection = false

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }

  lifecycle {
     create_before_destroy = true
  }
}

# Variables
# This will define the variables for the project ID, region, and zone
# The project ID is the ID of the project in the Google Cloud platform
# The region is the region in the Google Cloud platform
# The zone is the zone in the Google Cloud platform
variable "project_id" {
    default = "able-veld-462218-h4"
}
variable "region" { 
    default = "us-central1"
}
variable "zone" { 
    default = "us-central1-a"
}

# Outputs
output "cluster_name" {
  value = google_container_cluster.primary.name
}

output "cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "cluster_ca_certificate" {
  value = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
}
