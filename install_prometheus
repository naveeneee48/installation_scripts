#!/bin/bash

# Update packages
sudo apt update

# Create a system user for Prometheus
sudo useradd -rs /bin/false prometheus

# Create directories for Prometheus
sudo mkdir /etc/prometheus
sudo mkdir /var/lib/prometheus

# Download Prometheus
mkdir -p /tmp/prometheus && cd /tmp/prometheus
curl -s https://api.github.com/repos/prometheus/prometheus/releases/latest | grep browser_download_url | grep linux-amd64 | cut -d '"' -f 4 | wget -qi -

# Extract the downloaded archive
tar xvf prometheus*.tar.gz

# Move Prometheus files to the appropriate directories
sudo mv prometheus*/prometheus /usr/local/bin/
sudo mv prometheus*/promtool /usr/local/bin/
sudo mv prometheus*/consoles /etc/prometheus
sudo mv prometheus*/console_libraries /etc/prometheus

# Set ownership
sudo chown prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus

# Create a Prometheus systemd service
# Define the file path for the Prometheus systemd service
SERVICE_FILE="/etc/systemd/system/prometheus.service"

# Check if the service file already exists
if [ -e "$SERVICE_FILE" ]; then
    echo "Prometheus service file already exists."
    exit 1
fi

# Create and edit the Prometheus systemd service file
sudo tee "$SERVICE_FILE" > /dev/null << EOF
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \\
    --config.file /etc/prometheus/prometheus.yml \\
    --storage.tsdb.path /var/lib/prometheus/ \\
    --web.console.templates=/etc/prometheus/consoles \\
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

echo "Prometheus service file created successfully at: $SERVICE_FILE"

# Enable and start the Prometheus service
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
