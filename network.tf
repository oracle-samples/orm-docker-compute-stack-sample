## Copyright (c) 2024, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Network definitions

resource "oci_core_vcn" "generated_oci_core_vcn" {
	cidr_block = var.vcn_cidr_block
	compartment_id = var.compartment_ocid
	display_name = "vcn-oci-server"
}

resource "oci_core_subnet" "public_oci_core_subnet" {
  #Required
	vcn_id = oci_core_vcn.generated_oci_core_vcn.id	
	cidr_block = var.vcn_public_subnet_cidr_block
  compartment_id = var.compartment_ocid

  display_name = "public-subnet-vcn-oci-server"
  # Route table with internet gateway rule   
	route_table_id = oci_core_route_table.generated_oci_core_default_route_table.id 
	# Security list with ingress rules for web server and Jaeger ports
  security_list_ids = [oci_core_security_list.generated_oci_core_default_security_list.id]
}

resource "oci_core_subnet" "private_oci_core_subnet" {
  # Required
	vcn_id = oci_core_vcn.generated_oci_core_vcn.id
	cidr_block = var.vcn_private_subnet_cidr_block
	compartment_id = var.compartment_ocid

	display_name = "private-subnet-vcn-oci-server"
  # Route table with internet gateway rule   
	route_table_id = oci_core_vcn.generated_oci_core_vcn.default_route_table_id
	# Security list with ingress rules for web server and Jaeger ports
  security_list_ids = [oci_core_security_list.generated_oci_core_default_security_list.id]
}

resource "oci_core_internet_gateway" "generated_oci_core_internet_gateway" {
	# Required
	compartment_id = var.compartment_ocid
	vcn_id = oci_core_vcn.generated_oci_core_vcn.id

	display_name = "ig-vcn-oci-server"
	enabled = "true"
}

resource "oci_core_route_table" "generated_oci_core_default_route_table" {
  # Required
	compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.generated_oci_core_vcn.id
	
	display_name = "routetable-vcn-oci-server"

	route_rules {
		destination = "0.0.0.0/0"
		destination_type = "CIDR_BLOCK"
		network_entity_id = oci_core_internet_gateway.generated_oci_core_internet_gateway.id
	}
}

resource "oci_core_security_list" "generated_oci_core_default_security_list" {
  # Required
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_vcn.generated_oci_core_vcn.id
  
  display_name = "seclist-vcn-oci-server"

  egress_security_rules {
    description = "All traffic for all ports"
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol  = "all"
    stateless = "false"
  }

  ingress_security_rules {
    description = "Allow SSH remote login"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    description = "ICMP traffic for 3, 4"
    icmp_options {
      code = "4"
      type = "3"
    }
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "ICMP traffic for 3"
    icmp_options {
      code = "-1"
      type = "3"
    }
    protocol    = "1"
    source      = "10.0.0.0/16"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Allow traffic for web server"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = var.web_server_port
      min = var.web_server_port
    }
  }

  ingress_security_rules {
    description = "Allow traffic for Jaeger"
    protocol    = "6"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    stateless   = "false"
    tcp_options {
      max = var.trace_server_port
      min = var.trace_server_port
    }
  }

}
