# Test plan

- Compose configuration exits successfully.
- Site A returns HTTP 200 on localhost:8081.
- Site B returns HTTP 200 on localhost:8082.
- Prometheus readiness endpoint returns success on localhost:9090/-/ready.
- Grafana health endpoint returns success on localhost:3000/api/health.
- Prometheus, Node Exporter, and both Blackbox jobs report UP.
- app-a is attached only to Site A; app-b only to Site B.
- Published host ports bind to 127.0.0.1 only.

A successful container start alone is not a passing test. Save validation output as project evidence.
