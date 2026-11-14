# Verification and acceptance criteria

## Test environment

Record the Windows build, Ubuntu release, WSL version, Docker Desktop version, and repository commit alongside each formal evidence run. Do not record credentials.

## Application and monitoring acceptance

| ID | Test | Pass criterion | Evidence |
|---|---|---|---|
| DEP-01 | Compose model validation | `docker compose config --quiet` exits 0 | Validation transcript |
| DEP-02 | Service state | All six expected containers running; app healthchecks healthy | Compose status |
| APP-01 | Site A request | HTTP 200 from localhost:8081 | Browser capture and HTTP log |
| APP-02 | Site B request | HTTP 200 from localhost:8082 | Browser capture and HTTP log |
| OBS-01 | Prometheus readiness | `/-/ready` returns success | Browser capture and HTTP log |
| OBS-02 | Grafana health | `/api/health` returns healthy JSON | HTTP log |
| OBS-03 | Scrape coverage | Four active targets, all UP | Targets page and API output |
| OBS-04 | Alert rules | Three expected alert rules loaded and healthy | Rules page and API output |
| OBS-05 | Failure injection | SiteAUnavailable and SiteBUnavailable each enter firing when their site is stopped and clear after recovery | `scripts/test-alert-failure.ps1` transcripts |
| NET-01 | Application bridge membership | app-a is only on Site A; app-b only on Site B | Docker inspect output |
| NET-02 | Monitoring reachability | Blackbox Exporter is attached to both site bridges and monitoring bridge | Docker inspect output |
| NET-03 | East-west isolation | Site A cannot resolve/reach app-b; Site B cannot resolve/reach app-a | Negative wget probes |
| SEC-01 | Host binding | Published service ports bind to 127.0.0.1 | Docker port inspection |
| SEC-02 | Secret hygiene | `.env` ignored and not tracked | Git checks |

## WireGuard acceptance

| ID | Test | Pass criterion |
|---|---|---|
| VPN-01 | Peer handshake | Both peers report a recent handshake |
| VPN-02 | A-to-B routing | Site A client reaches Site B client |
| VPN-03 | B-to-A routing | Site B client reaches Site A client |
| VPN-04 | Prefix restriction | Unapproved test subnet is unreachable |
| VPN-05 | Failure detection | Stopping one peer breaks routed traffic |
| VPN-06 | Recovery | Restoring peer restores traffic |
| VPN-07 | Restart | Tunnel interfaces can be recreated and tests pass |

## CI acceptance

GitHub Actions validates the Compose model and shell syntax, starts the Compose stack on the hosted runner, checks application and health endpoints, asserts the Prometheus target state and alert rules, and runs the full Linux acceptance script. The WireGuard namespace and application alert failure-injection tests are local WSL2 tests and are not represented as CI tests.

## Result recording

A test is PASS only when its stated criterion is observed. A container being in the running state alone is not sufficient. Record failures and remediation rather than removing failed evidence.
