terraform {
    required_providers {
        google = {
            source = "hashicorp/google"
            version = "~> 4.0"
        }
    }
}

provider "google" {
  project = var.project_id
  region = var.region
  zone = var.zone
  credentials = file("able-veld-462218-h4-2b5706d3fc49.json")
}

resource "google_project_service" "cloud_functions" {
    project = var.project_id
    service = "cloudfunctions.googleapis.com"
    disable_on_destroy = false
}

resource "google_project_service" "cloud_run_api" {
    project = var.project_id
    service = "run.googleapis.com"
    disable_on_destroy = false
}

resource "google_project_service" "artifact_registry_api" {
    project = var.project_id
    service = "artifactregistry.googleapis.com"
    disable_on_destroy = false
}

resource "google_project_service" "compute_api" {
    project = var.project_id
    service = "compute.googleapis.com"
    disable_on_destroy = false
}


resource "google_project_service" "iap_api" {
    project = var.project_id
    service = "iap.googleapis.com"
    disable_on_destroy = false
}

# resource "google_project_service" "cloud_armor_api" {
#     project = var.project_id
#     service = "cloudarmor.googleapis.com"
#     disable_on_destroy = false
# }

resource "google_project_iam_member" "cloud_functions_invoker" {
    project = var.project_id
    role = "roles/cloudfunctions.invoker"
    member = "serviceAccount:${var.project_id}@appspot.gserviceaccount.com"
}

# Deploy Cloud Functions in multiple regions
resource "google_cloudfunctions_function" "serverless_api" {
  project = var.project_id
  for_each = toset(var.regions) # Iterar sobre cada região
  name     = "${var.function_name_prefix}-${replace(each.key, "-", "")}"
  region = each.key

  runtime     = "nodejs18"
  entry_point = "helloHttp"
  description = "A simple serverless API in ${each.key}"
  source_archive_bucket = google_storage_bucket.source_bucket[each.key].name
  source_archive_object = google_storage_bucket_object.source_archive[each.key].name
  trigger_http = true
  available_memory_mb = 128
  environment_variables = {
    GCP_REGION = each.key
  }

  depends_on = [
    google_project_service.cloud_functions,
    google_project_service.cloud_run_api,
    google_project_service.artifact_registry_api,
  ]
}

# Storage bucket to upload the function source code
resource "google_storage_bucket" "source_bucket" {
  for_each = toset(var.regions)
  name     = "${var.project_id}-gcf-source-${replace(each.key, "-", "")}" # Unique bucket name per region
  location = "US" # Buckets are global, but content is regional. Choose a multi-region location for the bucket if you prefer.
  uniform_bucket_level_access = true
  force_destroy = true
}

# Archive the source code and upload to storage
resource "google_storage_bucket_object" "source_archive" {
  for_each = toset(var.regions)
  name   = "${var.function_name_prefix}-${replace(each.key, "-", "")}-source.zip"
  bucket = google_storage_bucket.source_bucket[each.key].name
  source = data.archive_file.source_zip[each.key].output_path
  content_type = "application/zip"
}

data "archive_file" "source_zip" {
  for_each    = toset(var.regions)
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/src/function-source.zip"
}

# Create a Cloud Armor Security Policy 
# resource "google_compute_security_policy" "cloud_armor_policy" {
#   name        = var.cloud_armor_policy_name
#   description = "Basic Cloud Armor policy for web application"

#   rule {
#     action   = "deny"
#     priority = "1000"
#     match {
#       versioned_expr = "SRC_IPS_V1"
#       config {
#         src_ip_ranges = ["9.9.9.9/32"] # Example IP to block
#       }
#     }
#     description = "Deny access from a specific IP"
#   }

#   rule {
#     action   = "allow"
#     priority = 2147483647
#     match {
#         versioned_expr = "SRC_IPS_V1"
#         config {
#         src_ip_ranges = ["*"]
#         }
#     }
#     description = "Default allow rule"
#   }

# }

# Configure a Global External HTTP(S) Load Balancer 
resource "google_compute_url_map" "default" {
  name            = "${var.function_name_prefix}-url-map"
  default_service = google_compute_backend_service.default_backend.id
}

resource "google_compute_backend_service" "default_backend" {
  name        = "${var.function_name_prefix}-backend"
  protocol    = "HTTP"
  enable_cdn  = false
  # Note: A Cloud Function backend needs a serverless_neg, not an instance_group
  # The Cloud Functions themselves are the backends for the serverless NEGs.
  load_balancing_scheme = "EXTERNAL" # Changed from INTERNAL for Cloud Load Balancer 
#   security_policy = google_compute_security_policy.cloud_armor_policy.id

  # Add backends for each Cloud Function
  dynamic "backend" {
    for_each = google_cloudfunctions_function.serverless_api
    content {
      group = google_compute_region_network_endpoint_group.serverless_neg[backend.key].id
    }
  }
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  for_each              = toset(var.regions)
  name                  = "${var.function_name_prefix}-neg-${replace(each.key, "-", "")}"
  network_endpoint_type = "SERVERLESS"
  region                = each.key
  cloud_function {
    function = google_cloudfunctions_function.serverless_api[each.key].name
  }
}

resource "google_compute_target_http_proxy" "default" {
  name    = "${var.function_name_prefix}-http-proxy"
  url_map = google_compute_url_map.default.id
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "${var.function_name_prefix}-forwarding-rule"
  target     = google_compute_target_http_proxy.default.id
  port_range = "80"
  load_balancing_scheme = "EXTERNAL"
}