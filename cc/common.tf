terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.56.1"
    }
  }
  required_version = ">= 1.0.0"
}
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = var.ibmcloud_region
  zone             = var.ibmcloud_zone
}