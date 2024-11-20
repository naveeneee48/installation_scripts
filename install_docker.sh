#!/bin/bash

# Exit script if any command fails
set -e

echo "Updating package index..."
sudo apt-get update -y

echo "Installing prerequisites..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

echo "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Updating package index with Docker repository..."
sudo apt-get update -y

echo "Installing Docker Engine..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

echo "Adding the current user to the docker group..."
sudo usermod -aG docker $USER

echo "Enabling and starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Verifying Docker installation..."
docker --version

echo "Installation complete! Log out and log back in for the user group changes to take effect."

