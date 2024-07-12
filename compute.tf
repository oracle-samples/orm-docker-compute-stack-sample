## Copyright (c) 2024, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

# Compute Instances
data "template_file" "user_data" {
  template = file("oci-cloud-init.sh")

  vars = {
    username = var.username
    docker_repo_url = var.docker_repo_url
    docker_compose_version = var.docker_compose_version
    mount_dir = var.mount_dir
    web_server_port = var.web_server_port
    trace_server_port = var.trace_server_port
  }
}

resource "oci_core_volume" "block_volume" {
    availability_domain = data.oci_identity_availability_domains.ad_list.availability_domains[var.ad -1]["name"]
    compartment_id = var.compartment_ocid
    display_name = "block-volume-oci-server"
    size_in_gbs = var.volume_size_in_gbs
}

resource "oci_core_instance" "oci_server" {
  availability_domain = data.oci_identity_availability_domains.ad_list.availability_domains[var.ad -1]["name"]
  compartment_id = var.compartment_ocid
  display_name = var.compute_display_name
  shape = var.instance_shape

  create_vnic_details {
    assign_public_ip = true
    subnet_id = oci_core_subnet.public_oci_core_subnet.id
    display_name = "primary-vnic"
  }

  source_details {
    source_type = "image"
    source_id = lookup(data.oci_core_images.compute_images.images[0], "id")
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(data.template_file.user_data.rendered)
  }

}

resource "oci_core_volume_attachment" "block_volume_attachment" {
  depends_on = [oci_core_instance.oci_server, oci_core_volume.block_volume]
  
  attachment_type = "paravirtualized"
  instance_id = oci_core_instance.oci_server.id
  volume_id = oci_core_volume.block_volume.id  

  display_name = "block-volume-attachment-oci-server"
}