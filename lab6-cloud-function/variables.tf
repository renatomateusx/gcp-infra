variable "project_id" {
    type = string
    description = "The ID of the project to deploy the Cloud Function to"
}

variable "region" {
    type = string
    description = "The region to deploy the Cloud Function to"
}  

variable "zone" {
    type = string
    description = "The zone to deploy the Cloud Function to"
}

variable "regions" {
  description = "A list of GCP regions to deploy the Cloud Functions."
  type        = list(string)
  default     = ["us-central1"] # Exemplo de regiões multi-region 
}

variable "function_name_prefix" {
    type = string
    description = "The prefix for the Cloud Function name"
}

variable "cloud_armor_policy_name" {
    type = string
    description = "The name of the Cloud Armor policy to use"
}

variable "dynatrace_server" {
    type = string
    description = "The Dynatrace server to use"
}

variable "dynatrace_paas_token" {
    type = string
    description = "The Dynatrace PAAS token to use"
}