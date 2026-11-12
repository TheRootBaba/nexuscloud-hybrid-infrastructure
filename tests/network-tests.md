# Network Test Cases

| ID | Test | Expected | Result |
|---|---|---|---|
| NET-01 | Client pings OPNsense LAN 10.10.0.1 | Reply | Not run |
| NET-02 | Local client reaches local Ubuntu | Reply | Not run |
| NET-03 | WireGuard peers handshake | Recent handshake in wg show | Not run |
| NET-04 | Local peer pings 10.99.0.2 | Reply | Not run |
| NET-05 | Local host reaches remote LAN host | Reply where ICMP allowed | Not run |
| NET-06 | Remote has return route to local LAN | Return traffic works | Not run |
| NET-07 | Unrelated subnet not routed over VPN | No unintended route | Not run |

Commands: `ip -br address`, `ip route`, `sudo wg show`, `ping -c 4 10.10.0.1`, `ping -c 4 10.20.0.10`. ICMP may be blocked; inspect routes, firewall counters, and packet captures before concluding routing is broken.
