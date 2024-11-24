#!/bin/bash
if [ $# -ne 2 ]; then
  echo "Usage: $0 <client_machine_name> <client_tunnel_ip>"
  exit 1
fi
CWD=`pwd`
cd /etc/openvpn/easy-rsa
echo -n "Removing old keys and index record... "
sudo rm -f pki/issued/$1.crt pki/private/$1.key pki/reqs/$1.req
echo "Done"
echo -n "Creating new keys for $1 ... "
sudo sudo ./easyrsa --batch build-client-full $1 nopass
sudo cp pki/ca.crt $CWD
sudo cp pki/issued/$1.crt $CWD
sudo cp pki/private/$1.key $CWD
sudo cp /etc/openvpn/ta.key $CWD
sudo chmod 644 "$CWD"/$1.crt
sudo chmod 644 "$CWD"/$1.key
sudo chmod 644 "$CWD"/ca.crt
echo "Done"
echo "ifconfig-push $2 255.255.255.0" | sudo tee -a /etc/openvpn/ccd/$1
echo "Creating client Configuration..."
cat > "$CWD"/client.conf <<EOL
client
dev tun
dev-type tun
auth SHA256
tun-mtu 1500
proto tcp
remote <openvpn_server_public_ip> 443
route 10.8.0.0 255.255.255.0
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert $1.crt
key $1.key
ns-cert-type server
cipher AES-256-CBC
comp-lzo
verb 3
EOL
sudo systemctl restart openvpn@server.service

echo "$1 client.conf and  certificates are $1.crt , $!.key , ca.crt and ta.key there in $CWD dir and copy these 5 files and move it to openvpn client machine and save in /etc/openvpn"
echo "run 'sudo openvpn --config client.conf'  in client's /etc/openvpn folder'"
