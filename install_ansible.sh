#!/bin/bash

# Update package index
sudo apt update

# Install software-properties-common for adding repository
sudo apt install -y software-properties-common

# Add Ansible repository
sudo apt-add-repository --yes --update ppa:ansible/ansible

# Install Ansible
sudo apt install -y ansible

# Check Ansible version
ansible --version

echo "Ansible has been installed successfully."
