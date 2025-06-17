terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "~> 4.0"
    }

    helm = {
      source = "hashicorp/helm"
      version = "~> 2.7"
    }

    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.11"
    }
  }
}

provider "google" {
  project = var.project
  region = var.region
  zone = var.zone
  credentials = file("able-veld-462218-h4-2b5706d3fc49.json")
}

data "google_client_config" "current" {}

provider "kubernetes" {
  host = "https://${google_container_cluster.gke_cluster.endpoint}"
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = "https://${google_container_cluster.gke_cluster.endpoint}"
    token = data.google_client_config.current.access_token
    cluster_ca_certificate = base64decode(google_container_cluster.gke_cluster.master_auth.0.cluster_ca_certificate)
  }
}

resource "google_container_cluster" "gke_cluster" {
  name = "gke-cluster"
  location = var.zone
  initial_node_count = 2

  node_config {
    machine_type = "e2-medium"
    oauth_scopes = ["cloud-platform"]
  }

}

data "google_container_cluster" "gke_cluster" {
  name = "gke-cluster"
  location = var.zone
}

resource "helm_release" "dynatrace_operator" {
  name = "dynatrace-operator-alt"
  chart = "helm-charts/dynatrace-operator/chart/default"
  namespace = "dynatrace-alt"
  create_namespace = true
  version = "0.15.0"
  values = [
    file("dynatrace-values.yml")
  ]
}