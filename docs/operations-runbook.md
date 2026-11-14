# Operations runbook

## Start

```powershell
Set-Location C:\NexusCloud-v2
docker info
docker compose config --quiet
docker compose up -d
.\scripts\validate.ps1
```

## Health endpoints

| Component | URL |
|---|---|
| Site A | http://127.0.0.1:8081 |
| Site B | http://127.0.0.1:8082 |
| Grafana | http://127.0.0.1:3001 |
| Prometheus | http://127.0.0.1:9091/-/ready |
| Prometheus targets | http://127.0.0.1:9091/targets |
| Prometheus rules | http://127.0.0.1:9091/rules |

## Inspect service state

```powershell
docker compose ps
docker compose logs --tail 100
docker inspect nexuscloud-app-a
docker inspect nexuscloud-app-b
```

## Common failure procedures

| Symptom | Investigation | Corrective action |
|---|---|---|
| Docker CLI cannot reach engine | `docker info` | Start Docker Desktop; verify Ubuntu WSL integration |
| Port bind failure | `Get-NetTCPConnection -State Listen` | Identify owning process before changing mappings |
| App unhealthy | `docker compose logs app-a` or `app-b` | Inspect Nginx logs, bind mounts, and healthcheck |
| Probe target down | Prometheus Targets page; Blackbox logs | Check Blackbox membership on both site networks and app health |
| Grafana unavailable | Grafana health endpoint and logs | Check container status, port 3001, provisioning logs |
| Prometheus unavailable | Prometheus readiness and logs | Validate scrape/rule configuration and storage |
| VPN handshake stale | `wg show` inside router namespaces | Check namespace interfaces, underlay links, keys and routes |

## Stop and data retention

```powershell
docker compose down
```

Named Prometheus and Grafana volumes are retained. Do not use `-v` during normal shutdown or troubleshooting.

## WireGuard lifecycle

```powershell
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh up
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh test
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh status
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh restart
wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh down
```

The `down` action removes namespaces and the underlay bridge but preserves keys/configuration under `/etc/nexuscloud/wireguard/`.
