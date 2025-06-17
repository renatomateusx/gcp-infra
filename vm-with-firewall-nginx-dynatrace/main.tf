provider "google" {
    credentials = file("able-veld-462218-h4-2b5706d3fc49.json")
    project = var.project
    region = var.region
    zone = var.zone

}

resource "google_compute_network" "vpc_network" {
    name = "vpc-network"
}

resource "google_compute_firewall" "default" {
    name = "allow-http"
    network = google_compute_network.vpc_network.name
    allow {
        protocol = "tcp"
        ports = ["80"]
    }

    source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "ssh" {
    name = "allow-ssh"
    network = google_compute_network.vpc_network.name
    allow {
        protocol = "tcp"
        ports = ["22"]
    }

    source_ranges = ["0.0.0.0/0"]
    target_tags = ["sre-instance"]
}

resource "google_compute_instance" "vm_instance" {
    name = "sre-instance"
    machine_type = "e2-medium"
    zone = var.zone
    tags = ["sre-instance"]

    boot_disk {
        initialize_params {
            image = "debian-cloud/debian-11"
        }
    }

    network_interface {
        network = google_compute_network.vpc_network.name
        access_config {
            // Ephemeral IP
        }
    }

    metadata_startup_script = <<-EOF
        #!/bin/bash
        set -e # Sai imediatamente se um comando falhar

        echo "Atualizando pacotes do sistema..."
        apt-get update -y
        apt-get install -y nginx wget # Certifique-se que wget está instalado

        echo "Iniciando a instalação do Dynatrace OneAgent..."
        # Baixa o OneAgent. Remova --no-check-certificate em produção se possível.
        # Adicionado timeout e retries para maior robustez
        wget -O /tmp/Dynatrace-OneAgent.sh "https://${var.dynatrace_server}/api/v1/deployment/installer/agent/unix/default/latest?Api-Token=${var.dynatrace_paas_token}&arch=x86&flavor=default" \
            --timeout=30 --tries=5 --no-check-certificate || { echo "Falha ao baixar OneAgent!"; exit 1; }

        echo "Configurando permissões do script..."
        chmod +x /tmp/Dynatrace-OneAgent.sh

        echo "Executando o instalador do OneAgent..."
        # Executa o OneAgent. O --set-infra-only=false é o padrão, então pode ser omitido se quiser
        /tmp/Dynatrace-OneAgent.sh --set-app-log-content-access=true || { echo "Falha na instalação do OneAgent!"; exit 1; }

        echo "Instalação do Dynatrace OneAgent concluída (ou falhou, verificar logs)."
        # Opcional: Remova o instalador após a instalação
        rm -f /tmp/Dynatrace-OneAgent.sh
    EOF

}