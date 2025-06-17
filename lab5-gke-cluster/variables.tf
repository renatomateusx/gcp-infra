variable "project" {
    type = string
    description = "The project ID"
}

variable "region" {
    type = string
    description = "The region"
}

variable "zone" {
    type = string
    description = "The zone"   
}

variable "dynatrace_server" {
    type = string
    description = "The Dynatrace server"
}

variable "dynatrace_paas_token" {
    type = string
    description = "The Dynatrace PAAS token"
}