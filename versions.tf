## Copyright (c) 2024, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v 1.0 as shown at http://oss.oracle.com/licenses/upl

terraform {
  required_version = ">= 1.1.0, < 2.0.0"
  required_providers {
    oci = {
      source  = "hashicorp/oci"
      version = ">= 4.0.0"
    }  
  }
}
