## Copyright (c) 2024, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

provider "oci" {
  region = var.region
  tenancy_ocid = var.tenancy_ocid
}