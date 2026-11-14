# Security model

## Classification and scope

NexusCloud is a local training and portfolio lab. It is not a production security baseline, compliance assessment, or hardened cloud landing zone.

## Implemented controls

| Control | Implementation | Verification |
|---|---|---|
| Local-only service exposure | Host ports bind to 127.0.0.1 | Inspect Compose port mappings |
| Application segmentation | Separate Site A and Site B bridges | Inspect container network membership |
| Controlled cross-site probe | Blackbox is multi-homed; apps are not | Inspect Docker networks |
| Credential externalization | Grafana password supplied through local `.env` | Git ignore and tracked-file checks |
| VPN key separation | WireGuard material stored outside repository | Check root-owned config directory |
| Signup disabled | Grafana user signup disabled | Compose environment |
| Persistent data isolation | Named monitoring volumes | Compose volume inspection |

## Secrets handling

- Never commit `.env`, private keys, populated WireGuard peer files, tokens, or passwords.
- Rotate any credential that has been pasted into chat or committed.
- Keep WireGuard material under `/etc/nexuscloud/wireguard/` with root-only permissions.
- Screenshots must not show passwords, browser password managers, private keys, or secret environment variables.

## Threats and residual risks

- A local user with access to the Windows account can access local services and files.
- Loopback port binding does not protect against a compromised local host.
- Container images are pinned by tag, not digest; tags can move. A production supply-chain policy should pin digests and scan images.
- Node Exporter host mounts expose host metrics to the container; review this trust decision before adapting the stack to shared infrastructure.
- No TLS termination, identity provider, remote access gateway, or external notification receiver is deployed.
- The VPN simulation has no remote endpoint and does not protect Docker application traffic.

## Production hardening required before external exposure

Do not publish these services to a LAN or public internet without an explicit threat model, authenticated ingress, TLS, firewall policy, secret management, image digest pinning/scanning, backup/restore testing, and operational alert delivery.
