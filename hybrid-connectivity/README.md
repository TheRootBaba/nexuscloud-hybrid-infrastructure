# Hybrid Connectivity

Goal: private routed connectivity between 10.10.0.0/24 and 10.20.0.0/24 through WireGuard.

Build each site independently first. The first implementation terminates WireGuard on Linux gateway endpoints. Do not configure a second competing VPN endpoint on OPNsense during the initial iteration.

See [WireGuard guide](wireguard/README.md).
