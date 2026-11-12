variable "region" {
  description = "OCI region identifier, used only for an optional live deployment."
  type        = string
  default     = "eu-frankfurt-1"
}

variable "compartment_ocid" {
  description = "OCI compartment OCID; empty for local validation."
  type        = string
  default     = ""
}

variable "vcn_cidr" {
  description = "VCN CIDR."
  type        = string
  default     = "10.30.0.0/16"
}

variable "public_subnet_cidr" {
  description = "Optional public subnet CIDR."
  type        = string
  default     = "10.30.1.0/24"
}

variable "private_subnet_cidr" {
  description = "Private workload subnet CIDR."
  type        = string
  default     = "10.30.10.0/24"
}

variable "project_name" {
  description = "Resource name prefix."
  type        = string
  default     = "nexuscloud"
}
