variable "project" {
    type = string
    description = "The project ID"
    default = "able-veld-462218-h4"
}

variable "region" {
    type = string
    description = "The region"
    default = "us-central1"
}

variable "zone" {
    type = string
    description = "The zone"
    default = "us-central1-a"
}

variable "dynatrace_server" {
    type = string
    description = "The Dynatrace server"
    default = "gaq62932.live.dynatrace.com"
}

variable "dynatrace_token" {
    description = "Dynatrace API Token"
    type        = string
    default     = "${DYNATRACE_API_TOKEN}"
}