#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

# Install necessary dependencies
sudo apt install -y wget curl tar

# Install Prometheus
PROMETHEUS_VERSION="3.6.0"
echo "Installing Prometheus..."
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar -xvf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
sudo mv prometheus-${PROMETHEUS_VERSION}.linux-amd64 /etc/prometheus
sudo ln -s /etc/prometheus/prometheus /usr/local/bin/prometheus
sudo ln -s /etc/prometheus/promtool /usr/local/bin/promtool

# Prometheus configuration
cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']

  - job_name: 'node_exporter'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Prometheus systemd service
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/etc/prometheus/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/etc/prometheus/data --web.enable-lifecycle
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Install Grafana
GRAFANA_VERSION="12.2.0"
echo "Installing Grafana..."
wget https://dl.grafana.com/enterprise/release/grafana-enterprise-${GRAFANA_VERSION}.linux-amd64.tar.gz
tar -xvf grafana-enterprise-${GRAFANA_VERSION}.linux-amd64.tar.gz
sudo mv grafana-${GRAFANA_VERSION} /usr/share/grafana
sudo ln -s /usr/share/grafana/bin/grafana-server /usr/local/bin/grafana-server
sudo ln -s /usr/share/grafana/bin/grafana-cli /usr/local/bin/grafana-cli

# Grafana systemd service
cat <<EOF | sudo tee /etc/systemd/system/grafana.service
[Unit]
Description=Grafana
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/grafana-server --homepath=/usr/share/grafana
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Install Node Exporter
NODE_EXPORTER_VERSION="1.9.1"
echo "Installing Node Exporter..."
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar -xvf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
sudo mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 /etc/node_exporter
sudo ln -s /etc/node_exporter/node_exporter /usr/local/bin/node_exporter

# Node Exporter systemd service
cat <<EOF | sudo tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable, and start services
echo "Starting services..."
sudo systemctl daemon-reload
sudo systemctl enable prometheus.service grafana.service node_exporter.service
sudo systemctl start prometheus.service grafana.service node_exporter.service

# Output access details
echo "Installation complete!"
echo "Prometheus: http://<your-server-ip>:9090"
echo "Grafana: http://<your-server-ip>:3000 (default login: admin/admin)"
echo "Node Exporter: http://<your-server-ip>:9100/metrics"

