# Recovery Tests

Take VM snapshots and run only in the isolated lab.

| ID | Failure injected | Expected recovery | Result |
|---|---|---|---|
| REC-01 | Stop WireGuard on one peer | Tunnel fails; local LAN remains up | Not run |
| REC-02 | Restart WireGuard | Handshake and routed connectivity return | Not run |
| REC-03 | Stop Node Exporter | Prometheus target becomes DOWN | Not run |
| REC-04 | Restart Node Exporter | Metrics scraping resumes | Not run |
| REC-05 | Restart Prometheus | Scraping resumes | Not run |
| REC-06 | Remove then restore test route | Cross-site traffic fails then recovers | Not run |

Record impact, detection, diagnosis, recovery steps, and recovery time. Restore temporary changes after each test.
