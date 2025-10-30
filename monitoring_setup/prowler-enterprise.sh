#!/bin/bash
#===============================================================================
#  Script Name   : prowler-setup.sh
#  Description   : Automated setup for Prowler AWS Security Scanner
#  Author        : Naveen Kumar
#  Version       : v1.1
#  Date          : 2025-10-30
#
#  Purpose:
#    This script installs and configures the Prowler tool for AWS security and
#    compliance scanning. It sets up all dependencies, installs AWS CLI v2,
#    Prowler via pipx, and prepares helper scripts for multi-account scanning.
#
#  Target OS     : Ubuntu 20.04 / 22.04 (ARM or AMD)
#  Requirements  :
#    - Run as root or with sudo privileges
#    - Internet access for dependency download
#
#  Usage:
#    chmod +x prowler-setup.sh
#    sudo ./prowler-setup.sh
#
#  Output:
#    - /usr/local/bin/aws (AWS CLI)
#    - /root/.local/bin/prowler (via pipx)
#    - /opt/prowler/subaccounts.txt
#    - /opt/prowler/prowler-scan.sh
#    - /var/log/prowler-setup.log
#===============================================================================

set -e  # Exit immediately on error
LOG_FILE="/var/log/prowler-setup.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "🚀 Starting Prowler Setup..."
sleep 1

#===============================================================================
# 1. Update & Install Base Dependencies
#===============================================================================
echo "🔹 Updating system and installing dependencies..."
apt-get update -y
apt-get upgrade -y
apt-get install -y unzip curl git python3 python3-pip pipx jq

# Ensure pipx path is added
pipx ensurepath
export PATH="$PATH:/root/.local/bin:/home/ubuntu/.local/bin"

#===============================================================================
# 2. Install AWS CLI v2
#===============================================================================
echo "🔹 Installing AWS CLI v2..."
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
  AWSCLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip"
else
  AWSCLI_URL="https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip"
fi

curl "$AWSCLI_URL" -o "awscliv2.zip"
unzip -o awscliv2.zip
./aws/install

echo "✅ AWS CLI version:"
aws --version || echo "AWS CLI not found in PATH"

#===============================================================================
# 3. Install Prowler using pipx
#===============================================================================
echo "🔹 Installing Prowler via pipx..."
pipx install prowler
pipx upgrade prowler
echo "✅ Prowler installed successfully!"
prowler -v

#===============================================================================
# 4. Setup Directory Structure
#===============================================================================
echo "🔹 Creating directories for configuration and scripts..."
mkdir -p /opt/prowler
cd /opt/prowler

#===============================================================================
# 5. Create subaccounts list
#===============================================================================
echo "🔹 Creating subaccounts.txt..."
cat <<EOT > /opt/prowler/subaccounts.txt
817258123456
472234123456
EOT

echo "✅ Subaccounts list created at /opt/prowler/subaccounts.txt"

#===============================================================================
# 6. Create scan script for all AWS accounts
#===============================================================================
echo "🔹 Creating multi-account scan script (prowler-scan.sh)..."
cat <<'EOT' > /opt/prowler/prowler-scan.sh
#!/bin/bash
#====================================================================
#  Script Name  : prowler-scan.sh
#  Description  : Run Prowler scan across multiple AWS accounts.
#  Prerequisite : Each account must have an assumable IAM role with
#                 security audit privileges.
#====================================================================

LOG_DIR="/opt/prowler/logs"
mkdir -p "$LOG_DIR"

for account in $(cat /opt/prowler/subaccounts.txt); do
    echo "🔍 Scanning Account: $account"
    prowler -R arn:aws:iam::$account:role/<role_name> -b \
      | tee "$LOG_DIR/prowler_$account.log"
done

echo "✅ All scans completed! Logs available in $LOG_DIR"
EOT

chmod +x /opt/prowler/prowler-scan.sh
echo "✅ Scan script ready: /opt/prowler/prowler-scan.sh"

#===============================================================================
# 7. Verify setup
#===============================================================================
echo "🔹 Verifying setup..."
if command -v prowler >/dev/null 2>&1; then
    echo "✅ Prowler command found"
else
    echo "❌ Prowler installation failed" && exit 1
fi

#===============================================================================
# 8. Final Summary
#===============================================================================
echo "---------------------------------------------------------------"
echo "🎯 Prowler Setup Completed Successfully!"
echo "📦 Installed components:"
echo "  - AWS CLI v2"
echo "  - Prowler via pipx"
echo "  - subaccounts.txt configured"
echo "  - prowler-scan.sh created"
echo "  - Logs stored at: $LOG_FILE"
echo "  - To run scan: sudo /opt/prowler/prowler-scan.sh"
echo "---------------------------------------------------------------"
