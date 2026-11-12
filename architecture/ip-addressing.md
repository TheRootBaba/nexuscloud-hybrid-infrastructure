# IP Addressing Plan

| Segment / node | CIDR or IP | Purpose |
|---|---|---|
| Local LAN | 10.10.0.0/24 | Local client/server segment |
| OPNsense LAN | 10.10.0.1/24 | Local default gateway |
| Local Ubuntu | 10.10.0.10/24 | Linux workload |
| Local client | 10.10.0.20/24 | Test client |
| Remote LAN | 10.20.0.0/24 | Remote simulation |
| Remote Ubuntu | 10.20.0.10/24 | Remote workload |
| WireGuard transit | 10.99.0.0/30 | Point-to-point tunnel |
| Local / remote WG | 10.99.0.1 / .2 | Tunnel interface IPs |

Local routes to 10.20.0.0/24 through the local WireGuard peer; remote routes to 10.10.0.0/24 through the remote peer. Enable IPv4 forwarding on Linux gateways if they route between LAN and tunnel. WireGuard AllowedIPs must include the peer tunnel address and the opposite LAN prefix.

This is a logical address plan, not a ready-made VirtualBox adapter map. Adapter numbering and firewall interface names depend on your VM setup. Do not use these CIDRs if they overlap with your existing network.
