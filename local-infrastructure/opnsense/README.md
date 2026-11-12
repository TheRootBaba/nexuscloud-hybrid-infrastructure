# OPNsense Firewall

Role: local-site firewall and default gateway. Download from https://opnsense.org/download/.

1. Create a VM with two virtual adapters: WAN-side and LAN-side.
2. Attach LAN to VirtualBox internal network NEXUS-LOCAL.
3. Install OPNsense and identify interfaces from its console.
4. Assign LAN 10.10.0.1/24.
5. From a client on the LAN, open https://10.10.0.1.
6. Change default credentials immediately; never store them in Git.

Baseline: deny unsolicited WAN inbound; permit administration only from the intended management subnet; add explicit rules for required lab traffic; document source, destination, protocol, port, and purpose. Save a sanitized configuration backup after a working baseline.

Validate client-to-gateway and client-to-local-server reachability. Do not expose the management interface on a public/bridged network. No universal XML backup is provided because interface names and WAN/LAN assignments vary.
