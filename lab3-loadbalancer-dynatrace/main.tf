provider "google" {
    credentials = file("able-veld-462218-h4-2b5706d3fc49.json")
    project = var.project
    region = var.region
    zone = var.zone
}

resource "google_compute_network" "vpc_network" {
    name = "vpc-network"
}

resource "google_compute_firewall" "allow_http" {
    name = "allow-ssh-http"
    network = google_compute_network.vpc_network.name
    allow {
        protocol = "tcp"
        ports = ["22", "80"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["web-instance"]
}

data "template_file" "startup_script" {
    template = file("startup-script.sh")

    vars = {
        DYNATRACE_SERVER = var.dynatrace_server
        DYNATRACE_PAAS_TOKEN = var.dynatrace_paas_token
    }
}

resource "google_compute_instance_template" "web_instance" {
    name = "web-instance-template"
    machine_type = "e2-micro"

    disk {
        source_image = "debian-cloud/debian-11"
        auto_delete = true
        boot = true
    }
    
    network_interface {
        network = google_compute_network.vpc_network.name
        access_config {}
    }

    metadata = {
        startup-script = data.template_file.startup_script.rendered
    }
    
}


resource "google_compute_health_check" "http_health_check" {
    name = "http-health-check"
    check_interval_sec = 5
    timeout_sec = 5

    http_health_check {
        port = 80
    }
}


resource "google_compute_instance_group_manager" "web_mig" {
    name = "web-mig"
    base_instance_name = "web-instance"
    zone = var.zone
    target_size = 3

    version {
        instance_template = google_compute_instance_template.web_instance.id
    }

    named_port {
        name = "http"
        port = 80
    }

    auto_healing_policies {
        health_check = google_compute_health_check.http_health_check.id
        initial_delay_sec = 60
    }
}

resource "google_compute_backend_service" "web_backend_service" {
    name = "web-backend-service"
    port_name = "http"
    protocol = "HTTP"
    timeout_sec = 10
    health_checks = [google_compute_health_check.http_health_check.id]
    connection_draining_timeout_sec = 0

    backend {
        group = google_compute_instance_group_manager.web_mig.instance_group
    }

    depends_on = [google_compute_instance_group_manager.web_mig]
}

resource "google_compute_url_map" "web_url_map" {
    name = "web-url-map"    
    default_service = google_compute_backend_service.web_backend_service.id
}

resource "google_compute_target_http_proxy" "web_http_proxy" {
    name = "web-http-proxy"
    url_map = google_compute_url_map.web_url_map.id
}

resource "google_compute_global_forwarding_rule" "web_forwarding_rule" {
    name = "web-forwarding-rule"
    target = google_compute_target_http_proxy.web_http_proxy.id
    ip_address = google_compute_global_address.web_ip_address.address
    port_range = "80"
    ip_protocol = "TCP"
}

resource "google_compute_global_address" "web_ip_address" {
    name = "web-ip-address"
}