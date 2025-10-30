#!/bin/bash

set -e

#This script sets up Prowler by installing necessary dependencies, the AWS CLI, and creating configuration files for scanning AWS accounts.

# Update & install dependencies
apt-get update -y
apt-get upgrade -y
apt-get install -y unzip curl git python3 python3-pip pipx

# Ensure pipx is in PATH
pipx ensurepath

# Install AWS CLI v2
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install

# Install Prowler
pipx install prowler
prowler -v

# Create subaccounts.txt
cat <<EOT > /home/ubuntu/subaccounts.txt
817258123456
472234123456

EOT

# Create prowler-scan.sh
cat <<'EOT' > /home/ubuntu/prowler-scan.sh
#!/bin/bash
for account in $(cat /home/ubuntu/subaccounts.txt); do
    prowler -R arn:aws:iam::\$account:role/<role_name> -b
done
EOT

chmod +x /home/ubuntu/prowler-scan.sh
echo ":white_check_mark: Setup complete! Run scans with: ./prowler-scan.sh" >> /home/ubuntu/setup.log
