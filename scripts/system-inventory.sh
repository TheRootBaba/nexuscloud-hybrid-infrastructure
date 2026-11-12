#!/usr/bin/env bash
set -euo pipefail
echo "=== NexusCloud inventory ==="
date --iso-8601=seconds
echo "=== Host ==="
hostnamectl 2>/dev/null || hostname
echo "=== OS ==="
cat /etc/os-release 2>/dev/null || true
echo "=== CPU ==="
lscpu 2>/dev/null | grep -E '^(Architecture|CPU\(s\)|Model name):' || true
echo "=== Memory ==="
free -h 2>/dev/null || true
echo "=== Interfaces ==="
ip -br address 2>/dev/null || true
echo "=== Routes ==="
ip route 2>/dev/null || true
echo "=== Listening sockets ==="
ss -tulpn 2>/dev/null || true
