# Design Decisions

1. **Local-first:** VirtualBox avoids cloud bills and card prerequisites.
2. **Two private sites:** separate LANs make routing, firewall policy, and VPN behavior observable.
3. **Linux WireGuard endpoints initially:** simpler to inspect and debug. Moving VPN termination to OPNsense is a later extension, not part of the first build.
4. **Monitoring after connectivity:** reduce troubleshooting variables.
5. **OCI as IaC design:** validate Terraform locally; live deployment is not required and not implied.
