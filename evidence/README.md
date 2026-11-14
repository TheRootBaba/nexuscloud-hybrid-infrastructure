# Engineering evidence

This directory contains validation transcripts, screenshots and a recording from the running lab. The [verification matrix](../docs/verification.md) defines the checks represented by this evidence.

## Automated validation

The latest full local validation run is in `runs/20261113-231650/`. It records a successful check of:

- Six running containers and healthy application health checks.
- Four Prometheus targets in the UP state and three healthy alert rules.
- Separate Site A and Site B application networks, with cross-site access denied.
- Loopback-only bindings for published services.
- Bidirectional WireGuard client connectivity and an unreachable unapproved prefix.

The WireGuard test reported three successful packets in each direction with no packet loss. The denied-prefix test returned the expected unreachable result.

## Failure and recovery tests

The following transcripts record controlled application outages and recovery:

- `runs/20261113-230409/availability-failure-test.txt` — Site A alert fired and cleared after recovery.
- `runs/20261113-230611/availability-failure-test.txt` — Site B alert fired and cleared after recovery.
- `runs/20261113-230944/availability-failure-test.txt` — Site A alert held in the firing state for visual verification, then cleared after recovery.
- `runs/20261114-000228/availability-failure-test.txt`
- `runs/20261114-000740/availability-failure-test.txt`

## Screenshots

| Artifact | What it shows |
|---|---|
| `2026-11-13_01-site-a.png` | Site A response |
| `2026-11-13_02-site-b.png` | Site B response |
| `2026-11-13_03-prometheus-targets.png` | Four Prometheus targets |
| `2026-11-13_04-prometheus-rules.png` | Configured alert rules |
| `2026-11-13_05-github-actions-main.png` | Successful GitHub Actions run |
| `2026-11-13_06-github-docs-tree.png` | Repository documentation |
| `2026-11-13_07-prometheus-alert-firing.png` | Site A alert during controlled outage |
| `2026-11-13_08-grafana-dashboard.png` | Grafana overview with both sites UP and four healthy targets |
| `2026-11-13_09-docker-compose-health.png` | Compose services and validation output |
| `2026-11-13_10-wireguard-status.png` | WireGuard peer handshakes and transfer counters |
| `2026-11-13_11-wireguard-acceptance.png` | Bidirectional client tests and denied-prefix result |

## Demonstration recording

The recorded demonstration is stored at `demo/nexuscloud-2.0-demo.mp4`.

## Continuous integration

- [main — run 80](https://github.com/TheRootBaba/nexuscloud-hybrid-infrastructure/actions/runs/43527035923) — successful validation.
- [nexuscloud-v2 — run 81](https://github.com/TheRootBaba/nexuscloud-hybrid-infrastructure/actions/runs/43527045762) — successful validation.

## Handling

Do not commit `.env`, credentials, private keys, populated WireGuard configurations or tokens. Review screenshots and recordings before publishing to ensure they do not expose secrets or personal information.
