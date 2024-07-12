## Copyright (c) 2024, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

output "public-ip-for-compute-instance" {
  value = oci_core_instance.oci_server.public_ip
}
