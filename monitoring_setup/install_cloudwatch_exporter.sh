#!/bin/bash

# Variables
EXPORTER_VERSION="0.16.0"  # Update to the latest version as needed
EXPORTER_USER="cloudwatch-exporter"
EXPORTER_DIR="/opt/cloudwatch-exporter"
EXPORTER_JAR="cloudwatch_exporter.jar"
CONFIG_FILE="${EXPORTER_DIR}/cloudwatch_config.yml"
SERVICE_FILE="/etc/systemd/system/cloudwatch-exporter.service"
PORT="9106"

# Functions
create_config() {
    cat <<EOL > ${CONFIG_FILE}
region: us-east-1
metrics:
  - aws_namespace: AWS/RDS
    aws_metric_name: BackupStorageUsed
    dimensions:
      - DBInstanceIdentifier
    statistics: [Average, Minimum, Maximum]
    period_seconds: 300

  - aws_namespace: AWS/RDS
    aws_metric_name: SnapshotStorageUsed
    dimensions:
      - DBInstanceIdentifier
    statistics: [Average, Minimum, Maximum]
    period_seconds: 300
EOL
}

create_service_file() {
    cat <<EOL > ${SERVICE_FILE}
[Unit]
Description=Prometheus CloudWatch Exporter
After=network.target

[Service]
User=${EXPORTER_USER}
Group=${EXPORTER_USER}
ExecStart=/usr/bin/java -jar ${EXPORTER_DIR}/${EXPORTER_JAR} ${PORT} ${CONFIG_FILE}
Restart=always
Environment=JAVA_OPTS=-Xmx128m
WorkingDirectory=${EXPORTER_DIR}

[Install]
WantedBy=multi-user.target
EOL
}

# Script Execution

# Update and install prerequisites
echo "Installing prerequisites..."
sudo apt update && sudo apt install -y openjdk-11-jre wget

# Create a dedicated user
echo "Creating dedicated user for CloudWatch Exporter..."
sudo useradd --no-create-home --shell /bin/false ${EXPORTER_USER}

# Create necessary directories
echo "Setting up directories..."
sudo mkdir -p ${EXPORTER_DIR}
sudo chown ${EXPORTER_USER}:${EXPORTER_USER} ${EXPORTER_DIR}

# Download CloudWatch Exporter
echo "Downloading CloudWatch Exporter..."
wget -q "https://github.com/prometheus/cloudwatch_exporter/releases/download/v0.16.0/cloudwatch_exporter-0.16.0-jar-with-dependencies.jar" -O ${EXPORTER_DIR}/${EXPORTER_JAR}
sudo chown ${EXPORTER_USER}:${EXPORTER_USER} ${EXPORTER_DIR}/${EXPORTER_JAR}

# Create configuration file
echo "Creating configuration file..."
create_config
sudo chown ${EXPORTER_USER}:${EXPORTER_USER} ${CONFIG_FILE}

# Create service file
echo "Creating systemd service file..."
create_service_file

# Reload systemd and start the service
echo "Reloading systemd and starting CloudWatch Exporter service..."
sudo systemctl daemon-reload
sudo systemctl enable cloudwatch-exporter
sudo systemctl start cloudwatch-exporter

# Check service status
echo "CloudWatch Exporter service status:"
sudo systemctl status cloudwatch-exporter
