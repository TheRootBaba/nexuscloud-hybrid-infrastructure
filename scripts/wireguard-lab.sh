#!/usr/bin/env bash
set -euo pipefail

# Local two-site WireGuard simulation inside Ubuntu WSL2 network namespaces.
# Private keys and peer configs stay under /etc/nexuscloud/wireguard (root-only).

BASE=/etc/nexuscloud/wireguard
NS_A=nx-site-a
NS_B=nx-site-b
CLIENT_A=nx-client-a
CLIENT_B=nx-client-b
BR=nx-transit

need_root() { [[ ${EUID} -eq 0 ]] || { echo 'Run as root (from Windows: wsl -d Ubuntu -u root -- bash /mnt/c/NexusCloud-v2/scripts/wireguard-lab.sh up)'; exit 1; }; }
cleanup() {
  for ns in "$CLIENT_A" "$CLIENT_B" "$NS_A" "$NS_B"; do ip netns del "$ns" 2>/dev/null || true; done
  ip link del "$BR" 2>/dev/null || true
  ip link del nx-a-host 2>/dev/null || true
  ip link del nx-b-host 2>/dev/null || true
}

up() {
  need_root
  command -v wg >/dev/null && command -v wg-quick >/dev/null && command -v ip >/dev/null || { echo 'Missing wg, wg-quick, or iproute2'; exit 1; }
  [[ -c /dev/net/tun ]] || { echo '/dev/net/tun is missing'; exit 1; }
  modprobe wireguard
  cleanup
  install -d -m 700 "$BASE"
  umask 077
  if [[ ! -s "$BASE/site-a.key" || ! -s "$BASE/site-b.key" ]]; then
    wg genkey > "$BASE/site-a.key"
    wg genkey > "$BASE/site-b.key"
  fi
  local a_pub b_pub a_priv b_priv
  a_priv=$(cat "$BASE/site-a.key"); b_priv=$(cat "$BASE/site-b.key")
  a_pub=$(printf '%s' "$a_priv" | wg pubkey); b_pub=$(printf '%s' "$b_priv" | wg pubkey)

  ip netns add "$NS_A"; ip netns add "$NS_B"
  ip netns add "$CLIENT_A"; ip netns add "$CLIENT_B"
  ip link add "$BR" type bridge
  ip addr add 198.18.0.1/24 dev "$BR"
  ip link set "$BR" up

  ip link add nx-a-host type veth peer name nx-a-underlay
  ip link set nx-a-underlay netns "$NS_A"
  ip link set nx-a-host master "$BR"; ip link set nx-a-host up
  ip -n "$NS_A" addr add 198.18.0.2/24 dev nx-a-underlay
  ip -n "$NS_A" link set nx-a-underlay up; ip -n "$NS_A" link set lo up

  ip link add nx-b-host type veth peer name nx-b-underlay
  ip link set nx-b-underlay netns "$NS_B"
  ip link set nx-b-host master "$BR"; ip link set nx-b-host up
  ip -n "$NS_B" addr add 198.18.0.3/24 dev nx-b-underlay
  ip -n "$NS_B" link set nx-b-underlay up; ip -n "$NS_B" link set lo up

  ip -n "$NS_A" link add lan0 type veth peer name client0
  ip -n "$NS_A" addr add 10.77.10.1/24 dev lan0
  ip -n "$NS_A" link set lan0 up
  ip -n "$NS_A" link set client0 netns "$CLIENT_A"
  ip -n "$CLIENT_A" addr add 10.77.10.10/24 dev client0
  ip -n "$CLIENT_A" link set client0 up; ip -n "$CLIENT_A" link set lo up
  ip -n "$CLIENT_A" route add 10.77.20.0/24 via 10.77.10.1

  ip -n "$NS_B" link add lan0 type veth peer name client0
  ip -n "$NS_B" addr add 10.77.20.1/24 dev lan0
  ip -n "$NS_B" link set lan0 up
  ip -n "$NS_B" link set client0 netns "$CLIENT_B"
  ip -n "$CLIENT_B" addr add 10.77.20.10/24 dev client0
  ip -n "$CLIENT_B" link set client0 up; ip -n "$CLIENT_B" link set lo up
  ip -n "$CLIENT_B" route add 10.77.10.0/24 via 10.77.20.1

  ip netns exec "$NS_A" sysctl -q -w net.ipv4.ip_forward=1
  ip netns exec "$NS_B" sysctl -q -w net.ipv4.ip_forward=1

  cat > "$BASE/site-a.conf" <<EOF
[Interface]
Address = 10.77.0.1/30
ListenPort = 51820
PrivateKey = $a_priv

[Peer]
PublicKey = $b_pub
Endpoint = 198.18.0.3:51821
AllowedIPs = 10.77.0.2/32, 10.77.20.0/24
PersistentKeepalive = 15
EOF
  cat > "$BASE/site-b.conf" <<EOF
[Interface]
Address = 10.77.0.2/30
ListenPort = 51821
PrivateKey = $b_priv

[Peer]
PublicKey = $a_pub
Endpoint = 198.18.0.2:51820
AllowedIPs = 10.77.0.1/32, 10.77.10.0/24
PersistentKeepalive = 15
EOF
  chmod 600 "$BASE"/*.key "$BASE"/*.conf
  ip netns exec "$NS_A" wg-quick up "$BASE/site-a.conf"
  ip netns exec "$NS_B" wg-quick up "$BASE/site-b.conf"
  echo 'WireGuard site namespaces created.'
  echo 'Site A LAN: 10.77.10.0/24; client: 10.77.10.10'
  echo 'Site B LAN: 10.77.20.0/24; client: 10.77.20.10'
  echo 'Underlay: 198.18.0.0/24; tunnel: 10.77.0.0/30'
}

test_lab() {
  need_root
  echo '== Allowed route: Site A client -> Site B client =='
  ip netns exec "$CLIENT_A" ping -c 3 -W 2 10.77.20.10
  echo '== Return route: Site B client -> Site A client =='
  ip netns exec "$CLIENT_B" ping -c 3 -W 2 10.77.10.10
  echo '== Handshake timestamps =='
  ip netns exec "$NS_A" wg show site-a latest-handshakes
  ip netns exec "$NS_B" wg show site-b latest-handshakes
  echo '== Denied/unrouted destination =='
  if ip netns exec "$CLIENT_A" ping -c 1 -W 1 10.77.99.10; then
    echo 'FAIL: unexpected reachability to unapproved subnet'; exit 1
  else
    echo 'PASS: unapproved subnet is unreachable'
  fi
}

status_lab() {
  need_root
  ip netns exec "$NS_A" wg show || true
  ip netns exec "$NS_B" wg show || true
  ip -br link show "$BR" 2>/dev/null || true
}

restart_lab() {
  need_root
  ip netns exec "$NS_A" wg-quick down "$BASE/site-a.conf"
  ip netns exec "$NS_B" wg-quick down "$BASE/site-b.conf"
  ip netns exec "$NS_A" wg-quick up "$BASE/site-a.conf"
  ip netns exec "$NS_B" wg-quick up "$BASE/site-b.conf"
  test_lab
}

case "${1:-}" in
  up) up ;;
  test) test_lab ;;
  status) status_lab ;;
  restart) restart_lab ;;
  down) need_root; cleanup; echo 'WireGuard lab namespaces and transit bridge removed.' ;;
  *) echo "Usage: $0 {up|test|status|restart|down}"; exit 2 ;;
esac
