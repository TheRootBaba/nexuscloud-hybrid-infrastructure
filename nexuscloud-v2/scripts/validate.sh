#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
echo "[1/5] Compose configuration"
docker compose config >/dev/null
echo "[2/5] Site endpoints"
curl --fail --silent --show-error http://127.0.0.1:8081/ >/dev/null
curl --fail --silent --show-error http://127.0.0.1:8082/ >/dev/null
echo "[3/5] Prometheus readiness"
curl --fail --silent --show-error http://127.0.0.1:9090/-/ready
echo "[4/5] Grafana health"
curl --fail --silent --show-error http://127.0.0.1:3000/api/health
echo "[5/5] Prometheus targets"
curl --fail --silent --show-error http://127.0.0.1:9090/api/v1/targets | grep -E '"health":"up"' >/dev/null
echo "PASS: NexusCloud validation completed."
