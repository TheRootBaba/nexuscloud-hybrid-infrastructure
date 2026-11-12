# Ubuntu Server

Download Ubuntu Server LTS from https://ubuntu.com/download/server.

Set hostname (example: nexus-local), address 10.10.0.10/24, and gateway 10.10.0.1. Create a non-root administrator and enable SSH only on the lab/management network.

```bash
sudo apt update
sudo apt full-upgrade -y
sudo apt install -y curl wget vim git
hostnamectl
ip -br address
ip route
ss -tulpn
```

If OPNsense owns firewall policy, avoid adding duplicate/conflicting UFW rules without documenting which device enforces each policy.
