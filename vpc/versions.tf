terraform {
  required_version = ">= 0.14"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.56.1"
    }
  }
}