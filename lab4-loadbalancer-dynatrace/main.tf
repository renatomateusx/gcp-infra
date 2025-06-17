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
    target_tags = ["lab4-instance"]
}

data "template_file" "startup_script" {
    template = file("startup-script.sh")

    vars = {
        DYNATRACE_SERVER = var.dynatrace_server
        DYNATRACE_PAAS_TOKEN = var.dynatrace_paas_token
    }
}

resource "google_compute_instance_template" "vm_instance_template" {
    name = "vm-instance-template"
    machine_type = "e2-medium"
    tags = ["lab4-instance"]

    disk {
        source_image = "debian-cloud/debian-11"
        auto_delete = true
        boot = true
    }

    network_interface {
        network = google_compute_network.vpc_network.name
        access_config {
            // Empty config to allow external access
        }
    }

    metadata = {
        startup-script = data.template_file.startup_script.rendered
    }

    service_account {
        scopes = ["cloud-platform"]
    }
    
}

resource "google_compute_health_check" "http_health_check" {
    name = "lab4-http-health-check"
    check_interval_sec = 5
    timeout_sec = 5

    http_health_check {
        port = 80
    }
}

resource "google_compute_instance_group_manager" "vm_instance_group_manager" {
    name = "lab4-instance-group-manager"
    zone = var.zone
    base_instance_name = "lab4-instance"
    target_size = 2
    
    version {
        instance_template = google_compute_instance_template.vm_instance_template.id
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

resource "google_compute_backend_service" "vm_backend_service" {
    name = "lab4-backend-service"
    port_name = "http"
    protocol = "HTTP"
    timeout_sec = 10
    health_checks = [google_compute_health_check.http_health_check.id]

    backend {
        group = google_compute_instance_group_manager.vm_instance_group_manager.instance_group
    }
    
    depends_on = [google_compute_instance_group_manager.vm_instance_group_manager]
}

resource "google_compute_url_map" "vm_url_map" {
    name = "lab4-url-map"
    default_service = google_compute_backend_service.vm_backend_service.id
    depends_on = [google_compute_backend_service.vm_backend_service]
}

resource "google_compute_target_http_proxy" "vm_http_proxy" {
    name = "lab4-http-proxy"
    url_map = google_compute_url_map.vm_url_map.id
}

resource "google_compute_global_forwarding_rule" "vm_forwarding_rule" {
    name = "lab4-forwarding-rule"
    target = google_compute_target_http_proxy.vm_http_proxy.id
    ip_address = google_compute_global_address.vm_ip_address.address
    port_range = "80"
}

resource "google_compute_global_address" "vm_ip_address" {
    name = "lab4-ip-address"
}