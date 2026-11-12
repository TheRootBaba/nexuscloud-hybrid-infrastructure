output "vcn_id" {
  description = "VCN OCID after an optional apply."
  value       = oci_core_vcn.nexus.id
}
output "vcn_cidr" {
  description = "VCN CIDR block."
  value       = oci_core_vcn.nexus.cidr_blocks
}
output "public_subnet_id" {
  description = "Public subnet OCID after apply."
  value       = oci_core_subnet.public.id
}
output "private_subnet_id" {
  description = "Private subnet OCID after apply."
  value       = oci_core_subnet.private.id
}
