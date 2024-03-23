#!/bin/bash

# Check if the number of arguments is less than 1
if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <suricata_interface>"
    exit 1
fi

# Assign the first argument to the interface variable
suricata_interface="$1"

# Update package lists
sudo apt-get update

# Install Suricata and Oinkmaster
sudo apt-get install -y suricata oinkmaster

# Configure Suricata
sudo cp -raf /etc/suricata/suricata.yaml /etc/suricata/suricata.yaml.backup

# Download and enable community rules
sudo cp -raf suricata.yaml /etc/suricata/suricata.yaml

sudo cp -raf /etc/oinkmaster.conf /etc/oinkmaster.conf.backup

# Download Oinkmaster configuration file
sudo cp -raf oinkmaster.conf /etc/oinkmaster.conf

# Replace <interface> placeholder with the provided interface
sudo sed -i "s/<interface>/$suricata_interface/g" /etc/suricata/suricata.yaml

# Update Oinkmaster rules
sudo oinkmaster -C /etc/oinkmaster.conf -o /etc/suricata/rules

# Start Suricata service
sudo systemctl enable suricata
sudo systemctl start suricata

echo "Suricata and Oinkmaster installed and configured successfully."
