## Copyright (c) 2024, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Variables file

variable "tenancy_ocid" {}
variable "region" {}
variable "compartment_ocid" {}
variable "ssh_public_key" {}

# Compute display name
variable "compute_display_name" {
  type    = string
  default = "oci-server-01"
}

# Choose VCN CIDR block
variable "vcn_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}

# Choose public subnet CIDR block
variable "vcn_public_subnet_cidr_block" {
  type    = string
  default = "10.0.0.0/24"
}

# Choose private subnet CIDR block
variable "vcn_private_subnet_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}

# Choose an Availability Domain
variable "ad" {
  default = "1"
}

# Username
variable "username" {
  description = "Username"
  default     = "opc"
}

# Docker Repository URL
variable "docker_repo_url" {
  description = "Docker Repository URL"
  default     = "https://download.docker.com/linux/centos/docker-ce.repo"
}

# OS Image
variable "image_operating_system" {
  default = "Oracle Linux"
}
variable "image_operating_system_version" {
  default = "8"
}

# Compute Shape (Always Free Eligible)
variable "instance_shape" {
  description = "Instance Shape"
  default     = "VM.Standard.E2.1.Micro"
}

# Docker compose version
variable "docker_compose_version"{
  type= string
  description = "Docker Compose version"
  default = "2.17.2"
}

# Block volume mount directory
variable "mount_dir"{
  type= string
  description = "Block volume mount directory"
  default = "/scratch"
}

# Block volume size
variable "volume_size_in_gbs"{
  description = "Block volume size (GBs)"
  default = "50"
}

# Web server port
variable "web_server_port"{
  type= string
  description = "Web server port"
  default = "8080"
}

# Tracing service port
variable "trace_server_port"{
  type= string
  description = "Trace service version"
  default = "16686"
}
