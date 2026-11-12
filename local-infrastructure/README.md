# Local Infrastructure

Build the local site first: an OPNsense firewall/router, one Ubuntu Server, and optionally an Ubuntu client. Create a dedicated VirtualBox internal network named NEXUS-LOCAL.

Set OPNsense LAN to 10.10.0.1/24 and the Ubuntu server to 10.10.0.10/24 with gateway 10.10.0.1. Confirm local reachability before building the remote simulation.

See [OPNsense notes](opnsense/README.md) and [Ubuntu notes](ubuntu/README.md). Interface names depend on the VM adapter mapping.
