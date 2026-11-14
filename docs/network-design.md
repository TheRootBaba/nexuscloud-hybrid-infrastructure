# Network design

## Container networks

Docker Compose creates three user-defined bridge networks:

| Network | Members | Purpose |
|---|---|---|
| `nexuscloud-site-a` | app-a, blackbox | Isolated Site A application segment |
| `nexuscloud-site-b` | app-b, blackbox | Isolated Site B application segment |
| `nexuscloud-monitoring` | Prometheus, Grafana, Blackbox, Node Exporter | Monitoring and metrics transport |

Docker assigns bridge subnets dynamically. Service discovery uses Compose DNS names; fixed container IP addresses are not part of the design.

### Connectivity policy

- app-a can communicate on Site A bridge only.
- app-b can communicate on Site B bridge only.
- Blackbox Exporter is the only service intentionally attached to both site networks.
- Prometheus and Grafana remain on the monitoring bridge.
- Host-published service ports bind to loopback.

## WireGuard simulation addressing

| Segment | Address range | Purpose |
|---|---|---|
| Underlay | 198.18.0.0/24 | Isolated router-to-router transport |
| WireGuard tunnel | 10.77.0.0/30 | Encrypted point-to-point link |
| Site A LAN | 10.77.10.0/24 | Simulated client network |
| Site B LAN | 10.77.20.0/24 | Simulated client network |
| Negative test | 10.77.99.0/24 | Unapproved destination prefix |

The Site A client uses 10.77.10.10 and the Site B client uses 10.77.20.10. The WireGuard peers listen on UDP 51820 and UDP 51821 on the isolated underlay.

## Routing and cryptographic policy

Each router namespace has a WireGuard interface and routes to the opposite simulated LAN. Peer AllowedIPs are scoped to the remote tunnel address and intended remote LAN. Private keys and populated peer configurations are generated under `/etc/nexuscloud/wireguard/` and are not stored in the Git working tree.

## Packet path

```mermaid
sequenceDiagram
  participant A as Site A client namespace
  participant RA as Site A router namespace
  participant WG as WireGuard tunnel
  participant RB as Site B router namespace
  participant B as Site B client namespace
  A->>RA: ICMP packet to 10.77.20.10
  RA->>WG: Route to remote LAN; encrypt packet
  WG->>RB: UDP transport over isolated underlay
  RB->>B: Decrypt and forward to Site B LAN
  B-->>A: Reply follows reverse route and tunnel
```

## Scope caveat

This is a two-site logical topology simulated on one WSL2 host. It validates WireGuard handshakes, routed prefixes, reachability, and failure behavior. It is not an external network connection. Docker application traffic does not currently use this path.
