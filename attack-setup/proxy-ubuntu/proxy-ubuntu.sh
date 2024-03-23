#!/bin/bash

# Update package list
sudo apt-get update

# Install Dante server
sudo apt-get install -y dante-server

# Backup the original configuration file
sudo cp /etc/danted.conf /etc/danted.conf.bak

# Check if an interface is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <interface>"
    exit 1
fi

interface="$1"


# Create a new Dante configuration file
sudo bash -c 'cat <<EOL > /etc/danted.conf
logoutput: syslog
user.privileged: root
user.unprivileged: nobody

# The listening network interface or address.
internal: 0.0.0.0 port=1080

# The proxying network interface or address.
external: $interface

# socks-rules determine what is proxied through the external interface.
socksmethod: none

# client-rules determine who can connect to the internal interface.
clientmethod: none

client pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}
socks pass {
    from: 0.0.0.0/0 to: 0.0.0.0/0
}
EOL'

# Restart Dante service
sudo systemctl restart danted

# Enable Dante service to start on boot
sudo systemctl enable danted

echo "Dante SOCKS4 proxy installed and configured. Listening on port 1080."