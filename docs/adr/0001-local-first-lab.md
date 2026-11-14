# ADR-0001: Local-first infrastructure lab

- **Status:** Accepted
- **Decision date:** 2026-11-13

## Context

The project must demonstrate infrastructure and network engineering without requiring a paid cloud account, payment card, Kubernetes, or destruction of the existing VirtualBox assets. The development host runs Windows with Ubuntu WSL2 and Docker Desktop.

## Decision

Use Docker Compose for the two application sites and observability stack. Use Linux network namespaces and WireGuard inside WSL2 for the routed VPN exercise. Keep these planes separate until a supported and testable integration design exists.

## Consequences

### Positive
- Low-cost and reproducible on the existing workstation.
- Application segmentation and monitoring can be tested independently.
- VPN routing, allowed prefixes, handshake state, and failure recovery can be demonstrated without exposing a public endpoint.
- Existing VM disks, ISO files, and backups remain untouched.

### Trade-offs
- Both logical VPN sites share one host and one underlying WSL2 environment.
- Docker application traffic is not carried by the VPN.
- The lab does not prove remote-site latency, NAT traversal, WAN availability, or physical failure-domain independence.

## Reconsideration criteria

Revisit this decision only when a second reachable Linux host or a deliberate Docker/Linux routing integration is available and can be tested without compromising the host or exposing the local services.
