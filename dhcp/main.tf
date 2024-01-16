terraform {
  required_version = ">= 0.14"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.60.0"
    }
  }
}

resource "ibm_pi_dhcp" "dhcp_service" {
  pi_cloud_instance_id   = var.workspace_id
  pi_cidr                = var.machine_cidr
  pi_dhcp_name           = var.cluster_id
  pi_dhcp_snat_enabled   = true
  pi_dns_server          = var.dns_server
}

data "ibm_pi_dhcp" "dhcp_service" {
  pi_cloud_instance_id = var.workspace_id
  pi_dhcp_id           = ibm_pi_dhcp.dhcp_service.dhcp_id
}