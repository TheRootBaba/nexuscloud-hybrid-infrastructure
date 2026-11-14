# Observability design

## Components and responsibilities

| Component | Responsibility | Configuration |
|---|---|---|
| Prometheus | Scrapes metrics, evaluates alert rules, exposes query API | `monitoring/prometheus.yml` |
| Blackbox Exporter | Performs HTTP GET probes and reports probe metrics | `monitoring/blackbox.yml` |
| Node Exporter | Exposes host-visible Linux metrics | Docker Compose service |
| Grafana | Queries Prometheus and renders provisioned dashboards | `monitoring/grafana/provisioning/` |
| Alert rules | Detect site probe failures and missing scrape targets | `monitoring/alerts.yml` |

## Scrape topology

Prometheus has four expected active targets:

1. Prometheus self-scrape.
2. Node Exporter.
3. Blackbox probe for Site A.
4. Blackbox probe for Site B.

Blackbox Exporter uses the `http_2xx` module, sends an HTTP GET, and accepts HTTP 200 as the valid response.

## Alert rules

| Alert | Expression | Pending duration | Severity |
|---|---|---:|---|
| SiteAUnavailable | Site A `probe_success == 0` | 1 minute | critical |
| SiteBUnavailable | Site B `probe_success == 0` | 1 minute | critical |
| PrometheusTargetMissing | `up == 0` | 2 minutes | warning |

These are Prometheus alerting rules. No Alertmanager notification receiver is configured in this lab; rule evaluation is not equivalent to email, SMS, or paging delivery.

## Failure-injection verification

Run the controlled failure test from PowerShell:

```powershell
.\scripts\test-alert-failure.ps1 -Site SiteA
.\scripts\test-alert-failure.ps1 -Site SiteB
```

The script briefly stops the selected Nginx container, waits for the matching Prometheus alert to enter the firing state, restarts the container in a `finally` block, and verifies that the application healthcheck and HTTP probe recover and that the alert clears. Run it only when a short interruption to the selected demo site is acceptable. The script writes a timestamped transcript under `evidence/runs/`.

## Operator checks

- Prometheus targets: http://localhost:9091/targets
- Prometheus rules: http://localhost:9091/rules
- Prometheus alerts: http://localhost:9091/alerts
- Prometheus API: http://localhost:9091/api/v1/targets
- Grafana health: http://localhost:3001/api/health
- Grafana dashboards: http://localhost:3001/

A healthy container does not prove the application is available. The Blackbox probe is the application-level availability signal.
