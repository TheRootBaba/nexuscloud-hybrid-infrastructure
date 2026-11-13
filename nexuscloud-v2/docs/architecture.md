# Architecture and trust boundaries

Site A is a Docker bridge network containing app-a. Site B is a separate bridge network containing app-b. Monitoring is a third network containing Prometheus, Grafana, Blackbox Exporter, and Node Exporter.

Blackbox Exporter is deliberately multi-homed so it can probe both sites. Application containers are not attached to each other's network. Only loopback host ports are published.

Docker allocates bridge subnets automatically. Service discovery uses Compose DNS names, not fixed container IPs.

This release is a local simulation of two network zones. It does not provide a site-to-site VPN, cloud provider deployment, or production firewall. The WireGuard phase must verify WSL2 kernel support and container capabilities before a tunnel is added.
