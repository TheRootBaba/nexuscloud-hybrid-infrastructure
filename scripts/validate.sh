#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

pass() { printf 'PASS: %s\n' "$1"; }
fail() { printf 'FAIL: %s\n' "$1" >&2; exit 1; }

docker compose config --quiet || fail "Compose configuration"
pass "Compose configuration is valid"

containers=(
  nexuscloud-app-a nexuscloud-app-b nexuscloud-blackbox
  nexuscloud-node-exporter nexuscloud-prometheus nexuscloud-grafana
)
for container in "${containers[@]}"; do
  state="$(docker inspect --format '{{.State.Status}}' "$container")"
  [[ "$state" == "running" ]] || fail "$container is not running"
  pass "$container is running"
done

check_http() {
  local name="$1" url="$2"
  local code
  code="$(curl --silent --show-error --output /dev/null --write-out '%{http_code}' --max-time 10 "$url")"
  [[ "$code" =~ ^2 ]] || fail "$name returned HTTP $code"
  pass "$name returned HTTP $code"
}
check_http "Site A" "http://127.0.0.1:8081/"
check_http "Site B" "http://127.0.0.1:8082/"
check_http "Prometheus readiness" "http://127.0.0.1:9091/-/ready"
check_http "Grafana health" "http://127.0.0.1:3001/api/health"

python3 - <<'PY'
import json, urllib.request
def get(path):
    with urllib.request.urlopen("http://127.0.0.1:9091" + path, timeout=10) as response:
        return json.load(response)["data"]
targets = get("/api/v1/targets")["activeTargets"]
expected = {"prometheus", "node-exporter", "blackbox-site-a", "blackbox-site-b"}
jobs = {target["labels"]["job"] for target in targets}
assert len(targets) == 4, f"expected 4 targets, got {len(targets)}"
assert jobs == expected, f"unexpected jobs: {jobs}"
assert all(target["health"] == "up" for target in targets), targets
rules = [rule for group in get("/api/v1/rules")["groups"] for rule in group["rules"]]
assert len(rules) == 3, f"expected 3 rules, got {len(rules)}"
assert all(rule["health"] == "ok" for rule in rules), rules
print("PASS: all four Prometheus targets UP")
print("PASS: all three Prometheus alert rules healthy")
PY

python3 - <<'PY'
import json, subprocess
def networks(name):
    raw = subprocess.check_output(["docker","inspect","--format","{{json .NetworkSettings.Networks}}",name], text=True)
    return set(json.loads(raw))
a, b, blackbox = networks("nexuscloud-app-a"), networks("nexuscloud-app-b"), networks("nexuscloud-blackbox")
assert "nexuscloud-site-a" in a and "nexuscloud-site-b" not in a, a
assert "nexuscloud-site-b" in b and "nexuscloud-site-a" not in b, b
assert {"nexuscloud-site-a","nexuscloud-site-b","nexuscloud-monitoring"} <= blackbox, blackbox
print("PASS: application sites are isolated; Blackbox Exporter is multi-homed as designed")
PY

if docker exec nexuscloud-app-a sh -c 'wget -q -T 2 -O /dev/null http://app-b:80 >/dev/null 2>&1'; then
  fail "Site A unexpectedly reached Site B"
else
  pass "Site A cannot resolve/reach Site B service"
fi
if docker exec nexuscloud-app-b sh -c 'wget -q -T 2 -O /dev/null http://app-a:80 >/dev/null 2>&1'; then
  fail "Site B unexpectedly reached Site A"
else
  pass "Site B cannot resolve/reach Site A service"
fi

for pair in "nexuscloud-app-a:127.0.0.1:8081" "nexuscloud-app-b:127.0.0.1:8082" "nexuscloud-grafana:127.0.0.1:3001" "nexuscloud-prometheus:127.0.0.1:9091" "nexuscloud-blackbox:127.0.0.1:9115"; do
  container="${pair%%:*}"
  expected="${pair#*:}"
  bindings="$(docker port "$container")"
  count="$(printf '%s\n' "$bindings" | grep -c .)"
  [[ "$count" -eq 1 ]] || fail "$container has an unexpected number of host bindings"
  printf '%s\n' "$bindings" | grep -Fq "$expected" || fail "$container port is not bound to $expected"
  printf '%s\n' "$bindings" | grep -Eq -- '-> 127\.0\.0\.1:' || fail "$container is not loopback-only"
  pass "$container port bound to $expected only"
done

echo "PASS: NexusCloud acceptance validation completed."
