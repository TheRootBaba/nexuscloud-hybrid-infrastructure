# Installation and Build Guide

## Host preparation
1. Enable Intel VT-x/hardware virtualization in firmware if disabled.
2. Install VirtualBox: https://www.virtualbox.org/
3. Download Ubuntu Server LTS: https://ubuntu.com/download/server
4. Download OPNsense: https://opnsense.org/download/
5. Start with two VMs; add others in stages to protect host RAM.

## Phase 1 — Local site
1. Create a VirtualBox internal network named NEXUS-LOCAL.
2. Create an OPNsense VM with a WAN-side adapter and LAN adapter attached to NEXUS-LOCAL.
3. Install OPNsense; identify interface names from its console rather than assuming names.
4. Set LAN to 10.10.0.1/24.
5. Create an Ubuntu Server on NEXUS-LOCAL at 10.10.0.10/24, gateway 10.10.0.1.
6. Verify local connectivity and snapshot the VMs.

## Phase 2 — Remote simulation
1. Create a separate VirtualBox internal network named NEXUS-REMOTE.
2. Add remote Ubuntu workload 10.20.0.10/24.
3. Add a separate transport network/interface so WireGuard endpoints can reach each other. This is not either LAN.
4. Verify both sites independently before adding the VPN.

## Phase 3 — VPN
Follow [WireGuard setup](../hybrid-connectivity/wireguard/README.md). Configure forwarding and return routes deliberately. Test tunnel IPs first, then LAN-to-LAN connectivity.

## Phase 4 — Monitoring
Install Node Exporter on Linux hosts, then Prometheus and Grafana OSS on one host. Configure targets in monitoring/prometheus/prometheus.yml.

## Phase 5 — OCI IaC validation
Follow [Terraform guide](../cloud-infrastructure/terraform/README.md). Run fmt, init with backend disabled, and validate only. Do not run apply as part of this free local lab.

VirtualBox adapter numbering, network attachment types, and OPNsense interface names vary. Keep a written adapter-to-network map and verify it before changing settings.
