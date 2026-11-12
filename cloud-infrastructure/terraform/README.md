# OCI Network Terraform Design

This is an OCI VCN design exercise, not a deployed environment. Local checks:
```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```
Provider initialization may download the OCI provider; it does not create resources. Do not run terraform apply for this free local lab. A live apply requires an eligible OCI account, credentials, compartment OCID, and deliberate review of potential charges. Never commit API keys, credentials, or state files.
