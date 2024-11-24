#!/bin/bash

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

echo "Updating system packages..."
apt update && apt upgrade -y

echo "Installing OpenVPN and Easy-RSA..."
apt install -y openvpn easy-rsa

# Define OpenVPN directory paths
OPENVPN_DIR="/etc/openvpn"
EASYRSA_DIR="$OPENVPN_DIR/easy-rsa"
KEYS_DIR="$EASYRSA_DIR/keys"
CCD_DIR="$OPENVPN_DIR/ccd"

echo "Setting up Easy-RSA directory..."
mkdir -p $EASYRSA_DIR
cp -r /usr/share/easy-rsa/* $EASYRSA_DIR
chmod -R 700 $EASYRSA_DIR

echo "Configuring CA (Certificate Authority)..."
cd $EASYRSA_DIR
#./easyrsa init-pki
echo "yes" |./easyrsa init-pki
echo "Creating CA certificate..."
#./easyrsa build-ca nopass
./easyrsa --batch build-ca nopass


echo "Generating Server Certificate and Key..."
#./easyrsa gen-req server nopass
#./easyrsa sign-req server serveir
export SERVER_NAME=naveen-server
./easyrsa build-server-full $SERVER_NAME nopass
echo "Generating Diffie-Hellman parameters..."
./easyrsa gen-dh

cp /etc/openvpn/easy-rsa/pki/ca.crt /etc/openvpn
cp /etc/openvpn/easy-rsa/pki/dh.pem /etc/openvpn/dh2048.pem
cp /etc/openvpn/easy-rsa/pki/issued/$SERVER_NAME.crt /etc/openvpn/server.crt
cp /etc/openvpn/easy-rsa/pki/private/$SERVER_NAME.key /etc/openvpn/server.key


echo "Creating TLS Key for HMAC Security..."
openvpn --genkey --secret $EASYRSA_DIR/ta.key
cp $EASYRSA_DIR/ta.key /etc/openvpn/ta.key
#use this ta.key in <tls-auth /etc/openvpn/ta.key 0> in server.conf and <tls-auth /etc/openvpn/ta.key 1> for client.conf in client machine

echo "Setting up OpenVPN directories..."
mkdir -p $KEYS_DIR $CCD_DIR
#cp $EASYRSA_DIR/pki/ca.crt $EASYRSA_DIR/pki/private/server.key $EASYRSA_DIR/pki/issued/server.crt $EASYRSA_DIR/dh.pem $EASYRSA_DIR/ta.key $OPENVPN_DIR/

echo "Creating Server Configuration..."
cat > $OPENVPN_DIR/server.conf <<EOL
port 443
proto tcp
dev tun
ca $OPENVPN_DIR/ca.crt
cert $OPENVPN_DIR/server.crt
key $OPENVPN_DIR/server.key
dh $OPENVPN_DIR/dh2048.pem
auth SHA256
tun-mtu 1500
topology subnet
server 10.8.0.0 255.255.255.0
ifconfig-pool-persist $OPENVPN_DIR/ipp.txt
client-config-dir $CCD_DIR
keepalive 10 120
comp-lzo
persist-key
persist-tun
status /var/log/openvpn/openvpn-status.log
log-append /var/log/openvpn/openvpn.log
verb 4
#explicit-exit-notify 1
#client-to-client
#push "redirect-gateway def1 bypass-dhcp"
#push "dhcp-option DNS 8.8.8.8"
#push "dhcp-option DNS 8.8.4.4"
EOL

echo "Enabling IP Forwarding..."
sysctl -w net.ipv4.ip_forward=1
echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
sysctl -p /etc/sysctl.conf


#echo "Configuring UFW to Allow OpenVPN Traffic..."
#ufw allow 1194/udp
#ufw allow OpenSSH
#echo "Setting up NAT rules in UFW..."
#ufw route allow in on tun0 out on eth0
#ufw route allow in on eth0 out on tun0
#echo "Postrouting NAT rule for UFW..."
#iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE

echo "Restarting  OpenVPN services..."
#ufw reload
systemctl enable openvpn@server
systemctl start openvpn@server

echo "OpenVPN server setup completed!"
echo "You can create client certificates using Easy-RSA."

