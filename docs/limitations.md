# Limitations and next steps

NexusCloud 2.0 is a local infrastructure lab. It demonstrates selected infrastructure and operations techniques, but it is not the full hybrid-cloud architecture originally proposed. The current implementation and the unbuilt parts are distinguished below.

## Original scope versus current build

The initial design called for an on-premises virtual data center connected to OCI, with enterprise network segmentation, Linux services, identity, shared storage, WireGuard, Terraform-managed cloud resources, monitoring, centralized logging, backup and recovery.

OCI account and payment setup prevented hands-on deployment of the cloud environment. VirtualBox networking issues also made the original local virtual topology unreliable. The scope was reduced to a smaller lab that could be deployed and tested consistently.

The following items are not implemented in the current repository:

- VirtualBox-based on-premises virtual data center.
- OPNsense firewall deployment and policy enforcement.
- GNS3 enterprise network topology.
- Production VLAN trunking and inter-VLAN routing.
- OCI tenancy resources, VCNs, subnets, compute instances or cloud IAM.
- Terraform deployment of OCI resources.
- Centralized identity services and shared storage.
- Centralized log aggregation.
- Backup scheduling and a tested restore workflow.
- A real remote site or independent cloud endpoint.

The current Docker bridge segmentation and Linux namespace routing tests are narrower substitutes for selected network concepts. They do not establish that the unimplemented components above are present.

## Current implementation boundaries

### No independent remote site

Both WireGuard routers and both client networks run as Linux network namespaces inside one Ubuntu WSL2 environment on one Windows host. The topology validates peer handshakes, routing, allowed prefixes and basic failure behavior. It does not validate connectivity between independent machines, Internet paths, NAT traversal, WAN latency or separate failure domains.

### Application traffic does not use the VPN

The Docker Compose application and monitoring networks are separate from the WSL2 WireGuard namespaces. Site A and Site B web containers are isolated from each other on Docker bridges; they are not routed across the WireGuard tunnel. The VPN tests use dedicated Linux client namespaces.

### Local-only service exposure

Published service ports bind to the host loopback interface. This limits access to the local machine, but it is not a remote ingress design. There is no public load balancer, reverse proxy, managed DNS, external TLS termination or production ingress path.

### Alert evaluation without notification delivery

Prometheus evaluates the configured alert rules and exposes their firing state. No Alertmanager receiver is configured, so the project does not send email, chat, SMS or paging notifications.

### Lab-grade identity and secrets management

Grafana uses a locally configured administrator password. There is no centralized identity provider, SSO, role mapping, automated secret rotation or external secrets manager. Private WireGuard keys are kept outside the repository with restricted local permissions, but are not managed by a dedicated secrets platform.

### Single-host monitoring and storage

Prometheus, Grafana, the exporters and both application sites run on the same workstation. Named volumes preserve monitoring data across container recreation, but there is no highly available monitoring service, remote backup, retention policy review or disaster-recovery procedure.

### Image and host hardening

Container images use version tags rather than immutable digests. The lab does not include a full image-signing, vulnerability-scanning or automated patch-management pipeline. Node Exporter exposes host metrics from the Docker/WSL environment; its visibility is limited to that environment and should not be interpreted as full Windows host monitoring.

### CI scope

GitHub Actions validates the Compose stack and Linux acceptance checks on a hosted runner. The WSL2 WireGuard namespace tests and the interactive failure-injection tests are run locally; they are not part of the hosted CI workflow.

## Next engineering steps

1. Move one WireGuard peer to a second independent Linux host and verify connectivity over a real routed network.
2. Design and test a deliberate path for application traffic through the VPN, with explicit firewall policy and route validation.
3. Reintroduce an OPNsense/GNS3 network edge and validate VLAN and inter-VLAN firewall policy.
4. Deploy a real OCI environment when account and payment setup allow it, then provision it with Terraform.
5. Add Alertmanager with a test receiver and verify notification delivery and deduplication.
6. Add TLS termination and a documented ingress model before exposing any service outside loopback.
7. Introduce immutable image digests, vulnerability scanning and a patch/update policy.
8. Add centralized identity, shared storage, centralized logs and tested backup/restore procedures.
9. Define recovery objectives and test the failure of a remote site and its network path.
10. Extend CI with additional configuration, security and integration tests where the required infrastructure is available.

These items are future work, not capabilities of the current build.
