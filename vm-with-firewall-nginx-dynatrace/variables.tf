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

variable "dynatrace_paas_token" {
    type = string
    description = "The Dynatrace PAAS token"
    default = "dt0c01.4IDVWS3OEMAO7AYQHBIDFGHX.TRVIXEXOPOFF4S2TUS2QWSVSESQQS4VLXBMCOCVNR5SCF4XOFP4TQE5MU23UZYYD"
}