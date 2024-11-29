#!/bmonitoring

# Define variables
ALERTMANAGER_VERSION="0.26.0"  # Change to the latest version if needed
INSTALL_DIR="/opt/alertmanager"
CONFIG_DIR="/etc/alertmanager"
BIN_DIR="/usr/local/bin"
SERVICE_FILE="/etc/systemd/system/alertmanager.service"
ALERTMANAGER_CONFIG_FILE="$CONFIG_DIR/alertmanager.yml"
RULES_FILE="$CONFIG_DIR/alert-rules.yml"
DATA_DIR="/var/lib/prometheus"
USER="prometheus"

SLACK_WEBHOOK_URL="https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"  # Replace with your Slack webhook
SLACK_CHANNEL="#alerts"  # Replace with your desired Slack channel

# Update and install dependencies
echo "Updating system and installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y wget tar

# Create directories
echo "Creating directories..."
sudo mkdir -p $INSTALL_DIR $CONFIG_DIR
sudo chmod -R 755 $INSTALL_DIR $CONFIG_DIR

# Download and extract Alertmanager
echo "Downloading Alertmanager..."
wget https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz -P /tmp
tar -xzf /tmp/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz -C /tmp

# Move binaries
echo "Installing Alertmanager binaries..."
sudo mv /tmp/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/alertmanager $BIN_DIR/
sudo mv /tmp/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64/amtool $BIN_DIR/

# Clean up
echo "Cleaning up temporary files..."
rm -rf /tmp/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64*
rm -rf /tmp/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz

# Create Alertmanager config
echo "Creating Alertmanager configuration..."
sudo bash -c "cat > $ALERTMANAGER_CONFIG_FILE" << EOF
global:
  resolve_timeout: 5m

route:
  receiver: 'slack-notifications'

receivers:
  - name: 'slack-notifications'
    slack_configs:
      - api_url: '$SLACK_WEBHOOK_URL'
        channel: '$SLACK_CHANNEL'
        username: 'PrometheusAlertBot'
        title: '{{ .CommonAnnotations.summary }}'
        text: '{{ .CommonAnnotations.description }}'
EOF

# Create Alert Rules
echo "Creating alert rules..."
sudo bash -c "cat > $RULES_FILE" << EOF
groups:
  - name: monitoring-alerts
    rules:
      - alert: HighCPUUsage
        expr: 100 - (avg by(instance) (rate(node_cpu_seconds_total{mode="idle"}[1m])) * 100) > 80
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "High CPU usage on {{ \$labels.instance }}"
          description: "CPU usage is above 80% for 5 minutes on {{ \$labels.instance }}."

      - alert: NodeDown
        expr: up == 0
        for: 1m
        labels:
          severity: critical
        annotations:
          summary: "Node {{ \$labels.instance }} is down"
          description: "The node {{ \$labels.instance }} is not reachable."
EOF

# Set permissions
echo "Setting permissions..."
sudo chmod 600 $CONFIG_DIR/alertmanager.yml

# Create a systemd service for Alertmanager
echo "Creating systemd service..."
cat <<EOF | sudo tee $SERVICE_FILE
[Unit]
Description=Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=$BIN_DIR/alertmanager --config.file=$CONFIG_DIR/alertmanager.yml --storage.path=$INSTALL_DIR
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start Alertmanager
echo "Starting Alertmanager..."
sudo systemctl daemon-reload
sudo systemctl enable alertmanager
sudo systemctl start alertmanager

# Verify installation
if systemctl is-active --quiet alertmanager; then
  echo "Alertmanager has been installed and started successfully!"
else
  echo "There was an issue starting Alertmanager. Please check logs using: sudo journalctl -u alertmanager"
fi

# Print integration instructions
echo "To integrate Alertmanager with Prometheus, add the following to your Prometheus configuration file (prometheus.yml):"
echo "
alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - 'localhost:9093'  # Update this with Alertmanager's actual address
"

