# Deployment and configuration

## Prerequisites

- Windows with WSL2 and Ubuntu.
- Docker Desktop started and Ubuntu integration enabled.
- PowerShell.
- Internet access for image downloads.
- For the WireGuard exercise, Ubuntu kernel WireGuard support and `/dev/net/tun`.

## Configuration

Create the local environment file:

```powershell
if (-not (Test-Path .env)) { Copy-Item .env.example .env }
notepad .env
```

Set `GRAFANA_ADMIN_PASSWORD` to a unique strong value. The local `.env` is ignored by Git. Do not include its contents in evidence, logs, screenshots, or support requests.

## Deployment procedure

```powershell
Set-Location C:\NexusCloud-v2
docker info
docker compose config --quiet
docker compose pull
docker compose up -d
docker compose ps
.\scripts\validate.ps1
```

The Compose project uses named volumes for Prometheus and Grafana data. Recreating containers does not require deleting those volumes.

## Configuration change procedure

1. Review the Compose or monitoring configuration change.
2. Validate syntax with `docker compose config --quiet`.
3. Recreate only the affected service where possible.
4. Run the full validation script.
5. Review Prometheus targets and rules.
6. Record the change and its test evidence in the relevant pull request.

## Shutdown

```powershell
docker compose down
```

This stops and removes containers and project networks while preserving named volumes. `docker compose down -v` removes the volumes and permanently deletes retained metrics/dashboard state; use only for a deliberate reset.
