# outputs.tf
output "cloud_function_urls" {
  description = "URLs of the deployed Cloud Functions (internal for this setup)."
  value       = { for k, v in google_cloudfunctions_function.serverless_api : k => v.https_trigger_url }
}

output "load_balancer_ip" {
  description = "The IP address of the Global HTTP(S) Load Balancer."
  value       = google_compute_global_forwarding_rule.default.ip_address
}