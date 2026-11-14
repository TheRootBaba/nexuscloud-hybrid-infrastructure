#!/usr/bin/env bash
set -u
echo "Kernel: $(uname -r)"
echo "WireGuard tools:"
command -v wg || true
command -v wg-quick || true
echo "Module availability:"
if modinfo wireguard >/dev/null 2>&1; then
  echo "wireguard module metadata available"
else
  echo "wireguard module metadata unavailable"
fi
echo "TUN device:"
if [ -c /dev/net/tun ]; then
  echo "/dev/net/tun exists"
else
  echo "/dev/net/tun missing"
fi
echo "Docker engine:"
if docker info >/dev/null 2>&1; then
  docker info --format 'Server={{.ServerVersion}}'
else
  echo "Docker Engine is not reachable"
fi
echo "This script only reports readiness; it makes no network changes."
