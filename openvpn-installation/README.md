## Usage

First, get the script and make it executable:

```bash
wget https://raw.githubusercontent.com/naveeneee48/installation_scripts/main/openvpn-installation/openvpn-server-install.sh
chmod +x openvpn-server-install.sh
```
Then run it:
```sh
./openvpn-server-install.sh
```
You need to run the script as root

### 1. Files Required on the OpenVPN Server
The OpenVPN server needs the following files in its configuration directory (typically /etc/openvpn/):

| File                   | Description                                      | Path on Server                |
|------------------------|--------------------------------------------------|--------------------------------|
| `server.conf`          | Main server configuration file.                 | `/etc/openvpn/server.conf`    |
| `ca.crt`               | Certificate authority (CA) certificate.         | `/etc/openvpn/ca.crt`         |
| `server.crt`           | Server certificate, used to authenticate the server. | `/etc/openvpn/server.crt`     |
| `server.key`           | Server private key, paired with the server certificate. | `/etc/openvpn/server.key`     |
| `dh.pem` or `dh1024.pem` | Diffie-Hellman parameters for key exchange.   | `/etc/openvpn/dh.pem`         |
| `crl.pem` (optional)   | Certificate revocation list (if managing revoked certificates). | `/etc/openvpn/crl.pem`        |
| `client-configs/ccd`   | Per-client configuration files specifying tunnel IPs. | `/etc/openvpn/ccd/` (one file per client) |
| `ta.key` (optional)    | TLS authentication key for additional security. | `/etc/openvpn/ta.key`         |

### 2. Files Required on OpenVPN Clients
Each client needs the following files to establish a secure connection. These files are typically stored in a directory on the client machine, e.g., /etc/openvpn/client/ or C:\Program Files\OpenVPN\config for Windows clients.

| File                  | Description                                                    | Path on Client                     |
|-----------------------|----------------------------------------------------------------|-------------------------------------|
| `client.ovpn` or `client.conf` | The OpenVPN client configuration file for the specific client (e.g., `one.ovpn`). | `/etc/openvpn/client/client.ovpn`  |
| `ca.crt`              | Certificate authority (CA) certificate, used to authenticate the server. | `/etc/openvpn/client/ca.crt`       |
| `client-name.crt`     | Client-specific certificate (e.g., `one.crt`, `two.crt`, `three.crt`). | `/etc/openvpn/client/one.crt` (etc.) |
| `client-name.key`     | Client-specific private key (e.g., `one.key`, `two.key`, `three.key`). | `/etc/openvpn/client/one.key` (etc.) |
| `ta.key` (optional)   | TLS authentication key, if used.                              | `/etc/openvpn/client/ta.key`       |

### 3. Tunnel IP Suggestions

To assign static tunnel IPs for clients, you use OpenVPN's **ccd (client-config-dir)** feature.

**Suggested Tunnel IP Range**:  
Use the private IP range **10.8.0.0/24** for the tunnel network.

**Example Tunnel IP Assignments**:  
- **Server**: `10.8.0.1` (default gateway for clients)  
- **Client One**: `10.8.0.10`  
- **Client Two**: `10.8.0.11`  
- **Client Three**: `10.8.0.12`

### 4. Troubleshooting Steps
Ping Test: Verify connectivity between clients using the `ping` command.

`ping 10.8.0.10`

### 4. SSH into the Other Client

From one OpenVPN client, you can SSH into another client using its OpenVPN tunnel IP and password-based authentication.

#### Command:
`ssh username@10.8.0.10`

**Firewall Rules**: Check firewall rules on both clients and the server to ensure SSH traffic is not blocked.


