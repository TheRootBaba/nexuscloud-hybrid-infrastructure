# Reference OCI network. Not provisioned by the local-lab workflow.
# Live apply requires valid OCI account details and may incur charges.
provider "oci" {
  region = var.region
}

resource "oci_core_vcn" "nexus" {
  compartment_id = var.compartment_ocid
  cidr_blocks    = [var.vcn_cidr]
  display_name   = "${var.project_name}-vcn"
  dns_label      = "nexuscloud"
}

resource "oci_core_internet_gateway" "nexus" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.nexus.id
  display_name   = "${var.project_name}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.nexus.id
  display_name   = "${var.project_name}-public-rt"
  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.nexus.id
  }
}

resource "oci_core_security_list" "public" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.nexus.id
  display_name   = "${var.project_name}-public-security"
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options { min = 22 max = 22 }
  }
  ingress_security_rules {
    protocol = "1"
    source   = var.vcn_cidr
  }
}

resource "oci_core_security_list" "private" {
  compartment_id = var.compartment_ocid
  vcn_id         = oci_core_vcn.nexus.id
  display_name   = "${var.project_name}-private-security"
  egress_security_rules {
    destination = var.vcn_cidr
    protocol    = "all"
  }
  ingress_security_rules {
    protocol = "6"
    source   = var.vcn_cidr
    tcp_options { min = 22 max = 22 }
  }
  ingress_security_rules {
    protocol = "1"
    source   = var.vcn_cidr
  }
}

resource "oci_core_subnet" "public" {
  compartment_id            = var.compartment_ocid
  vcn_id                    = oci_core_vcn.nexus.id
  cidr_block                = var.public_subnet_cidr
  display_name              = "${var.project_name}-public-subnet"
  dns_label                 = "public"
  route_table_id            = oci_core_route_table.public.id
  security_list_ids         = [oci_core_security_list.public.id]
  prohibit_public_ip_on_vnic = false
}

resource "oci_core_subnet" "private" {
  compartment_id             = var.compartment_ocid
  vcn_id                     = oci_core_vcn.nexus.id
  cidr_block                 = var.private_subnet_cidr
  display_name               = "${var.project_name}-private-subnet"
  dns_label                  = "private"
  security_list_ids          = [oci_core_security_list.private.id]
  prohibit_public_ip_on_vnic = true
}
