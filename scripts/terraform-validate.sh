#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TF_DIR="$ROOT/cloud-infrastructure/terraform"
command -v terraform >/dev/null 2>&1 || {
  echo "terraform is not installed; install Terraform or adapt for OpenTofu." >&2
  exit 127
}
cd "$TF_DIR"
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
echo "Validation complete. No terraform apply was run."
