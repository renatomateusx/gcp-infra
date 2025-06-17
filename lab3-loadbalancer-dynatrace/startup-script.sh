#!/bin/bash

set -e # Sai imediatamente se um comando falhar

echo "Atualizando pacotes do sistema..."
apt-get update
apt-get install -y nginx
systemctl start nginx
systemctl enable nginx

echo "<h1>Instância Web pronta 🚀</h1>" > /var/www/html/index.nginx-debian.html
systemctl enable nginx
systemctl start nginx

echo "Iniciando a instalação do Dynatrace OneAgent..."
# Baixa o OneAgent. Remova --no-check-certificate em produção se possível.
# Adicionado timeout e retries para maior robustez
wget -O /tmp/Dynatrace-OneAgent.sh "https://${DYNATRACE_SERVER}/api/v1/deployment/installer/agent/unix/default/latest?Api-Token=${DYNATRACE_PAAS_TOKEN}&arch=x86&flavor=default" \
    --timeout=30 --tries=5 --no-check-certificate || { echo "Falha ao baixar OneAgent!"; exit 1; }

echo "Configurando permissões do script..."
chmod +x /tmp/Dynatrace-OneAgent.sh

echo "Executando o instalador do OneAgent..."
# Executa o OneAgent. O --set-infra-only=false é o padrão, então pode ser omitido se quiser
/tmp/Dynatrace-OneAgent.sh --set-app-log-content-access=true || { echo "Falha na instalação do OneAgent!"; exit 1; }

echo "Instalação do Dynatrace OneAgent concluída (ou falhou, verificar logs)."
# Opcional: Remova o instalador após a instalação
rm -f /tmp/Dynatrace-OneAgent.sh