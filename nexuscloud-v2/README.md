# NexusCloud 2.0 — Local Hybrid Cloud & Network Security Lab

A free, reproducible lab for Windows + WSL2 + Docker. It begins with two isolated application networks and an observability stack. VPN/routing work is added only after the baseline passes.

## Goals
- No paid cloud account, payment card, Kubernetes, or VirtualBox dependency.
- Isolated Site A and Site B Docker bridge networks.
- Prometheus, Grafana, Blackbox Exporter, and Node Exporter.
- Repeatable startup, health checks, and validation scripts.
- No secrets committed to Git.

## Topology
Windows host → WSL2 Ubuntu + Docker Engine
- Site A network: app-a (nginx)
- Site B network: app-b (nginx)
- Monitoring network: Prometheus, Grafana, Blackbox Exporter, Node Exporter
- Blackbox Exporter joins both site networks only to probe their HTTP health.
- All published ports bind to 127.0.0.1 only.

This is a local network-segmentation simulation, not a production VPN or a real cloud deployment.

## Requirements
- Windows 10/11, WSL2 Ubuntu, Docker Engine reachable from Ubuntu.
- At least 4 GB free RAM recommended, 2 GB free disk space.
- Internet for first-time image downloads.

## Quick start
1. Copy .env.example to .env and set a long unique Grafana password.
2. Run docker compose config.
3. Run docker compose up -d.
4. Browse Site A at http://localhost:8081, Site B at http://localhost:8082, Grafana at http://localhost:3000, Prometheus at http://localhost:9090.
5. Run bash scripts/validate.sh.

PowerShell helpers are in scripts/start.ps1 and scripts/validate.ps1.

## Stop
Run docker compose down. Named volumes preserve Grafana and Prometheus data. To intentionally erase data, use docker compose down -v.

## Phases
1. Foundation: WSL2/Docker preflight, isolated networks, monitoring, validation.
2. Security: least privilege, secrets, firewall demonstrations, image scanning.
3. Hybrid connectivity: WireGuard only after confirming WSL2 kernel/userspace support.
4. Portfolio: diagrams, test results, screenshots, runbooks.

Never expose admin/monitoring ports to the public internet. Never commit .env, private keys, tokens, or credentials.
See docs/architecture.md, docs/windows-setup.md, and docs/test-plan.md.
