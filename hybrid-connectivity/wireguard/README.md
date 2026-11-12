# WireGuard Site-to-Site Tunnel

## Plan
- Local tunnel IP: 10.99.0.1/30
- Remote tunnel IP: 10.99.0.2/30
- Local LAN: 10.10.0.0/24
- Remote LAN: 10.20.0.0/24

For the first prototype, install WireGuard on two Ubuntu gateway VMs. Each endpoint must reach the other over a separate isolated VirtualBox transport network. Do not assume tunnel reachability before verifying this transport path.

## Install on both peers
```bash
sudo apt update
sudo apt install -y wireguard
umask 077
wg genkey | tee privatekey | wg pubkey > publickey
```

Keep each private key only on its endpoint; exchange public keys only. Never commit keys.

Copy wg0.conf.example to /etc/wireguard/wg0.conf after replacing placeholders. Restrict permissions:
```bash
sudo install -m 600 wg0.conf /etc/wireguard/wg0.conf
sudo systemctl enable --now wg-quick@wg0
sudo wg show
```

Enable forwarding on gateway endpoints that route between LAN and tunnel:
```bash
sudo sysctl -w net.ipv4.ip_forward=1
```
Persist with a file in /etc/sysctl.d/ containing net.ipv4.ip_forward=1, then run sudo sysctl --system.

Configure routes at both LAN gateways for the opposite LAN via the local WireGuard endpoint. Use narrow firewall rules. Do not use 0.0.0.0/0 AllowedIPs for this site-to-site design.

Test handshake, tunnel IP ping, opposite LAN reachability, return route, and packet capture. See ../../tests/network-tests.md.
