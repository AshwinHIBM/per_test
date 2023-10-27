data "ibm_resource_group" "rg_pvs_ipi_rg" {
  name = var.resource_group
}

resource "ibm_tg_gateway" "transit_gateway" {
  name           = "tg-${var.cluster_id}"
  location       = var.vpc_region
  global         = true
  resource_group = data.ibm_resource_group.rg_pvs_ipi_rg.id
}

resource "ibm_tg_connection" "tg_connection_vpc" {
  gateway      = resource.ibm_tg_gateway.transit_gateway.id
  network_type = "vpc"
  name         = "tg-${var.cluster_id}-conn-vpc"
  network_id   = var.vpc_crn
}

resource "ibm_tg_connection" "tg_connection_pvs" {
  gateway      = resource.ibm_tg_gateway.transit_gateway.id
  network_type = "power_virtual_server"
  name         = "tg-${var.cluster_id}-conn-pvs"
  network_id   = var.service_instance_crn
}
