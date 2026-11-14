# NexusCloud 2.0

A local infrastructure engineering lab focused on network segmentation, service monitoring, secure routing and operational testing.

NexusCloud began as a larger hybrid-cloud design exercise: an on-premises virtual data center connected to an Oracle Cloud Infrastructure (OCI) environment. The original concept included enterprise VLANs, routing and firewall policy, Linux services, identity and shared storage, WireGuard site-to-site connectivity, Terraform-managed OCI networking and compute, monitoring, logging, backup and recovery.

Getting the original environment running end to end brought practical constraints. OCI account and payment setup blocked hands-on deployment of the cloud side, while VirtualBox networking problems made the local virtual network unreliable. Rather than present an unbuilt architecture as a finished deployment, I narrowed the scope and built a smaller environment that I could run, inspect and test repeatedly.

The current version is therefore a working local lab, not the full original hybrid-cloud design. It concentrates on Docker-based service isolation, Prometheus/Grafana monitoring, controlled availability failures and a separate WireGuard routing simulation. The OCI and broader enterprise components remain design goals, not deployed features.

## Current implementation

The project has two independent parts:

- **Application and monitoring:** Docker Compose runs two Nginx sites on separate bridge networks. Prometheus collects metrics, Blackbox Exporter probes both sites, Grafana displays service health, and Node Exporter provides host metrics.
- **VPN routing exercise:** Linux network namespaces model two site routers and two clients. WireGuard connects the router namespaces and routes traffic between the client networks.

The Docker application containers do not send traffic through the WireGuard tunnel.

| Area | Implementation | Verification |
|---|---|---|
| Application sites | Two Nginx containers on separate Docker bridges | HTTP 200 and container health checks |
| Network segmentation | Independent Site A and Site B application networks | Cross-site DNS and connectivity denial |
| Availability monitoring | Prometheus and Blackbox Exporter | Four expected scrape targets UP |
| Metrics dashboard | Grafana with provisioned Prometheus data source and dashboard | Dashboard and health endpoint |
| Host metrics | Node Exporter | Prometheus scrape target |
| Alerting | Site availability and missing-target rules | Controlled outage, firing, recovery and alert clear |
| Encrypted routing | WireGuard between Linux router namespaces | Bidirectional client traffic, handshake and prefix restriction tests |
| Repeatable validation | PowerShell and Bash scripts | Local acceptance checks and GitHub Actions |

## Architecture

See [architecture](docs/architecture.md) for the system diagram and service relationships. The [network design](docs/network-design.md) documents bridge membership, addressing and routing. [Observability](docs/observability.md) covers metrics, probes and alert rules.

## Requirements

- Windows 10 or 11 with WSL2 and Ubuntu
- Docker Desktop with WSL integration enabled
- PowerShell 5.1 or later
- For the VPN exercise: WireGuard kernel support in WSL2, `wireguard-tools`, `iproute2` and `iputils-ping`
- Internet access for initial image and package downloads

## Start the application and monitoring stack

From PowerShell:

```powershell
Set-Location C:\NexusCloud-v2
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
notepad .env
docker info
docker compose config --quiet
docker compose up -d
.\scripts\validate.ps1
```

Set a unique `GRAFANA_ADMIN_PASSWORD` in the local `.env` file before starting the stack. The file is ignored by Git and must not be committed.

| Service | Local address |
|---|---|
| Site A | http://localhost:8081 |
| Site B | http://localhost:8082 |
| Grafana | http://localhost:3001 |
| Prometheus | http://localhost:9091 |
| Blackbox Exporter | http://localhost:9115 |

## Start and test the WireGuard lab

From Windows PowerShell:

```powershell
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh up
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh test
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh status
```

The script creates two router namespaces, two client namespaces, an isolated underlay bridge and a WireGuard tunnel. Private keys and populated peer configurations are stored under `/etc/nexuscloud/wireguard/`, outside the repository.

To remove the namespaces and bridge:

```powershell
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh down
```

## Test alerting and recovery

The failure-injection script stops one application container, waits for its Prometheus alert to fire, restarts the container and checks that the service and probe recover.

```powershell
.\scripts\test-alert-failure.ps1 -Site SiteA
.\scripts\test-alert-failure.ps1 -Site SiteB
```

Run this only when a brief interruption to the selected site is acceptable. Each run writes a transcript under `evidence/runs/`.

## Validation and evidence

Run the local acceptance suite with:

```powershell
.\scripts\validate.ps1
```

The Bash equivalent is `scripts/validate.sh`. GitHub Actions runs the Compose configuration checks, shell syntax checks, service smoke tests, Prometheus checks and Linux network/port validation.

Test transcripts, screenshots and the recorded demonstration are listed in the [evidence register](evidence/README.md). The [verification matrix](docs/verification.md) describes the acceptance criteria.

## Operations

- Start: `docker compose up -d`
- Check state: `docker compose ps`
- View logs: `docker compose logs --tail 100`
- Validate: `.\scripts\validate.ps1`
- Stop while preserving monitoring data: `docker compose down`

Avoid `docker compose down -v` unless the Prometheus and Grafana volumes are intentionally being deleted.

## Documentation

- [System architecture](docs/architecture.md)
- [Network design](docs/network-design.md)
- [Observability and alerting](docs/observability.md)
- [Deployment and configuration](docs/deployment.md)
- [Security model](docs/security.md)
- [Operations runbook](docs/operations-runbook.md)
- [Verification matrix](docs/verification.md)
- [Known limitations and next steps](docs/limitations.md)
- [Architecture decision record](docs/adr/0001-local-first-lab.md)
- [Engineering evidence](evidence/README.md)

## Repository

https://github.com/TheRootBaba/nexuscloud-hybrid-infrastructure
