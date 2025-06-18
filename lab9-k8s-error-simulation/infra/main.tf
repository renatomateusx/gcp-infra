terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
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

# This will configure the Kubernetes provider
# The provider will be used to create resources in the Kubernetes platform
# The provider will be configured with the host, token, and cluster CA certificate
data "google_client_config" "default" {}

# This will configure the Kubernetes provider
# The provider will be used to create resources in the Kubernetes platform
# The provider will be configured with the host, token, and cluster CA certificate
provider "kubernetes" {
  host  = "https://${google_container_cluster.primary.endpoint}"
  token = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
}

# This will configure the Helm provider
# The provider will be used to create resources in the Helm platform
# The provider will be configured with the host, token, and cluster CA certificate
provider "helm" {
  kubernetes {
    host  = "https://${google_container_cluster.primary.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth.0.cluster_ca_certificate)
  }
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

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["https://www.googleapis.com/auth/cloud-platform"]
  }
}

# Create a namespace for the Dynatrace operator
# This will create a namespace for the Dynatrace operator
# The namespace will be named "dynatrace"
# The namespace will be created in the GKE cluster
# The namespace will be created in the zone "us-central1-a"
# The namespace will be created in the project "able-veld-462218-h4"
# The namespace will be created in the region "us-central1"
resource "kubernetes_namespace" "dynatrace" {
  metadata {
    name = "dynatrace"
  }
}

# This will install the Dynatrace operator
# The operator will be installed in the namespace "dynatrace"
# The operator will be installed in the GKE cluster
# The operator will be installed in the zone "us-central1-a"
# The operator will be installed in the project "able-veld-462218-h4"
# The operator will be installed in the region "us-central1"
resource "helm_release" "dynatrace_operator" {
  name       = "dynatrace-operator"
  repository = "https://helm.dynatrace.com"
  chart      = "dynatrace-operator"
  namespace  = kubernetes_namespace.dynatrace.metadata[0].name
  create_namespace = false
  version    = "0.15.0"

  values = [
    templatefile("${path.module}/dynatrace-values.tpl.yml", {
      dynatrace_url         = var.dynatrace_server,
      dynatrace_paas_token  = var.dynatrace_paas_token,
      dynatrace_api_token   = var.dynatrace_api_token
    })
  ]
}

# This will create a Dynakube CRD
# The CRD will be created in the namespace "dynatrace"
# The CRD will be created in the GKE cluster
# The CRD will be created in the zone "us-central1-a"
# The CRD will be created in the project "able-veld-462218-h4"
# The CRD will be created in the region "us-central1"
resource "kubernetes_manifest" "dynakube_crd" {
  manifest = yamldecode(templatefile("${path.module}/dynakube.tpl.yml", {
    dynatrace_url = var.dynatrace_server
  }))

  depends_on = [helm_release.dynatrace_operator]
}



# Variables
# This will define the variables for the project ID, region, and zone
# The project ID is the ID of the project in the Google Cloud platform
# The region is the region in the Google Cloud platform
# The zone is the zone in the Google Cloud platform
# The dynatrace_server is the server of the Dynatrace platform
# The dynatrace_paas_token is the token of the Dynatrace platform
variable "project_id" {
    default = "able-veld-462218-h4"
}
variable "region" { 
    default = "us-central1"
}
variable "zone" { 
    default = "us-central1-a"
}
variable "dynatrace_server" { 
    default = "gaq62932.live.dynatrace.com"
}
variable "dynatrace_paas_token" { 
    default = "dt0c01.4IDVWS3OEMAO7AYQHBIDFGHX.TRVIXEXOPOFF4S2TUS2QWSVSESQQS4VLXBMCOCVNR5SCF4XOFP4TQE5MU23UZYYD"
}
variable "dynatrace_api_token" { 
    default = "ZHQwYzAxLjRJRFZXUzNPRU1BTzdBWVFIQklERkdIWC5UUlZJWEVYT1BPRkY0UzJUVVMyUVdTVlNFU1FRUzRWTFhCTUNPQ1ZOUjVTQ0Y0WE9GUDRUUUU1TVUyM1VaWVlE"
}

#output
output "template_test" {
  value = fileexists("${path.module}/dynatrace-values.tpl.yml")
}
