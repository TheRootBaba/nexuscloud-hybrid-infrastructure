# Troubleshooting

## VM cannot reach gateway
- Check the adapter is attached to the intended VirtualBox network.
- Check guest IP, prefix, and default route: `ip -br address`, `ip route`.
- Confirm OPNsense LAN is up and has the expected address.

## WireGuard has no handshake
- Run `sudo wg show` on both peers.
- Verify Endpoint IP/UDP port is reachable on the transport network.
- Verify public keys; private keys must remain on their endpoints.
- Check UDP firewall rules and system clock.

## Handshake works, remote LAN does not
- Check AllowedIPs on both peers.
- Enable IPv4 forwarding on Linux gateway endpoints.
- Verify routes in both directions; return routing is essential.
- Inspect firewall counters and capture packets.

## Prometheus target is DOWN
- Check Node Exporter: `systemctl status prometheus-node-exporter`.
- Check port: `ss -lntp | grep 9100`.
- From Prometheus host: `curl -sS http://TARGET:9100/metrics | head`.
- Allow TCP 9100 only from the monitoring host.

## Terraform validation fails
- Run `terraform fmt -recursive`.
- Run `terraform init -backend=false`.
- Run `terraform validate`; resolve the first reported error.
- Do not add cloud credentials merely to validate syntax.
