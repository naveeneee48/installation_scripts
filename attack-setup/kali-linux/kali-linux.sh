#!/bin/bash

# Check if the proxy IP address is provided as an argument
if [ -z "$1" ]; then
    echo "Usage: $0 <proxy_ipaddress>"
    exit 1
fi

# Update the package list
sudo apt update

# Install necessary packages
sudo apt install -y proxychains
proxychains_conf="/etc/proxychains.conf"


# Check if the file exists
if [ -e "$proxychains_conf" ]; then
    echo "Proxychains configuration file found. Creating a backup..."
    sudo cp "$proxychains_conf" "$proxychains_conf.bak"
    echo "Backup created successfully."
else
    echo "Proxychains configuration file not found. Skipping backup."
fi


# Backup the original configuration files
sudo cp /etc/proxychains.conf /etc/proxychains.conf.bak
sudo cp /etc/proxychains4.conf /etc/proxychains4.conf.bak

# Update the configuration files
sudo sed -i "s/static_chain/dynamic_chain/g" /etc/proxychains.conf
sudo sed -i "s/static_chain/dynamic_chain/g" /etc/proxychains4.conf

# Set the provided proxy IP address in the configuration files
sudo sed -i "s/127.0.0.1/$1/g" /etc/proxychains.conf
sudo sed -i "s/127.0.0.1/$1/g" /etc/proxychains4.conf

echo "ProxyChains installation and configuration completed."
