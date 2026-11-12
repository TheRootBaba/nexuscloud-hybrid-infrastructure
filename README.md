# NexusCloud — Secure Hybrid Cloud Infrastructure Lab

[![MIT](https://img.shields.io/badge/license-MIT-blue)](LICENSE) ![Local-first](https://img.shields.io/badge/cost-free%20%2F%20local-success)

NexusCloud is a practical hybrid infrastructure lab built with free software on one computer. It models a local site and a separate remote/cloud-side site, connects them using WireGuard, applies routing and firewall controls, and monitors Linux systems.

**Focus:** networking, Linux administration, security controls, cloud architecture, operations, and troubleshooting. This is not a Kubernetes or CI/CD project.

> **Honest status:** This repository contains build instructions and configuration templates. The physical lab has not been marked deployed or tested. OCI Terraform files are for local validation and architecture demonstration; they do not create cloud resources unless you separately configure credentials and run an apply.

## Architecture

```text
                  YOUR COMPUTER / VIRTUALBOX
        +----------------------+  +----------------------+
        | LOCAL SITE           |  | REMOTE SITE SIM       |
        | 10.10.0.0/24          |  | 10.20.0.0/24          |
        |                      |  |                      |
        | OPNsense firewall    |  | Ubuntu workload      |
        | Ubuntu server        |--| WireGuard endpoint   |
        | Ubuntu client        |  |                      |
        +----------------------+  +----------------------+
                    \              /
                     +-- WireGuard-+
                        10.99.0.0/30

        Prometheus + Grafana monitor Linux hosts.
        Separate OCI Terraform design is validated locally.
```

## Example IP plan

| Component | Address |
|---|---|
| Local LAN | `10.10.0.0/24` |
| OPNsense LAN | `10.10.0.1` |
| Local Ubuntu | `10.10.0.10` |
| Local client | `10.10.0.20` |
| Remote LAN | `10.20.0.0/24` |
| Remote Ubuntu | `10.20.0.10` |
| WireGuard transit | `10.99.0.0/30` |
| Local / remote tunnel IPs | `10.99.0.1` / `10.99.0.2` |

Check for overlap with your home/office network before using these example ranges.

## Free stack

- VirtualBox — virtualization: https://www.virtualbox.org/
- OPNsense — firewall/routing: https://opnsense.org/
- Ubuntu Server LTS — Linux workloads: https://ubuntu.com/download/server
- WireGuard — VPN: https://www.wireguard.com/
- Terraform or OpenTofu — IaC: https://developer.hashicorp.com/terraform / https://opentofu.org/
- Prometheus, Grafana OSS, Node Exporter — monitoring
- Wireshark — packet analysis: https://www.wireshark.org/

No paid cloud, subscription, hosting, or payment card is required for the local implementation. Do not upload ISO files, private keys, credentials, or Terraform state.

## Build order

1. Read [installation](docs/installation.md) and [architecture/IP plan](architecture/ip-addressing.md).
2. Build the local OPNsense + Ubuntu network first.
3. Build the remote simulation as a separate VirtualBox network.
4. Add WireGuard only after both sites work independently.
5. Add monitoring after routed connectivity is stable.
6. Run Terraform formatting/validation only; do not apply cloud resources.
7. Execute the [test plan](tests/README.md) and record real evidence in [validation results](docs/validation-results.md).

## Repository map

- `architecture/` — topology, IP plan, design decisions.
- `local-infrastructure/` — OPNsense and Ubuntu notes.
- `hybrid-connectivity/` — WireGuard templates and routing.
- `cloud-infrastructure/terraform/` — OCI network IaC design.
- `monitoring/` — Prometheus/Grafana configuration.
- `scripts/` — repeatable local checks.
- `tests/` — network, firewall, and recovery tests.
- `docs/` — build guide, security, troubleshooting, evidence.

## Hardware guidance

A 12-core CPU is sufficient. RAM is the main constraint. Start with two VMs, then add others in stages. Suggested allocations: OPNsense 2 GB RAM/2 vCPU/12 GB disk; each Ubuntu server 2 GB/2 vCPU/15 GB; client 1.5 GB/1 vCPU/12 GB. These are virtual disk capacities. Avoid running every VM simultaneously if the host becomes slow.

## Security

Keep management interfaces on isolated/host-only networks. Do not expose SSH, Grafana (3000), Prometheus (9090), or Node Exporter (9100) to the public internet. Change default passwords. Use placeholders in tracked configs; store real secrets only on the VMs.

## Status

Repository foundation prepared; hands-on deployment and test evidence remain. See [project status](docs/project-status.md).

## License

MIT — see [LICENSE](LICENSE).
