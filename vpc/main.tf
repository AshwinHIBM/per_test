terraform {
  required_version = ">= 0.14"
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.60.0"
    }
  }
}

data "ibm_resource_group" "rg" {
  name = var.resource_group
}

resource "ibm_is_vpc" "vpc" {
  name           = "vpc-${var.cluster_id}-power"
  classic_access = false
  resource_group = data.ibm_resource_group.rg.id
}

resource "time_sleep" "wait_for_vpc" {
  depends_on      = [ibm_is_vpc.vpc]
  create_duration = var.wait_for_vpc
}

resource "ibm_is_public_gateway" "ocp_vpc_gateway" {
  count = var.publish_strategy == "Internal" ? 1 : 0
  name  = "${var.cluster_id}-gateway"
  vpc   = data.ibm_is_vpc.ocp_vpc.id
  zone  = data.ibm_is_subnet.ocp_vpc_subnet.zone
}

resource "ibm_is_subnet" "vpc_subnet" {
  depends_on               = [time_sleep.wait_for_vpc]
  name                     = "vpc-subnet-${var.cluster_id}"
  vpc                      = data.ibm_is_vpc.ocp_vpc.id
  resource_group           = data.ibm_resource_group.rg.id
  total_ipv4_address_count = 256
  zone                     = "us-south-1"
  tags                     = [var.cluster_id]
}

resource "ibm_is_subnet_public_gateway_attachment" "subnet_public_gateway_attachment" {
  count          = var.publish_strategy == "Internal" ? 1 : 0
  subnet         = data.ibm_is_subnet.ocp_vpc_subnet.id
  public_gateway = data.ibm_is_public_gateway.ocp_vpc_gateway[0].id
}

data "ibm_is_vpc" "ocp_vpc" {
  name = ibm_is_vpc.vpc.name
}

data "ibm_is_subnet" "ocp_vpc_subnet" {
  name = ibm_is_subnet.vpc_subnet.name
}

data "ibm_is_public_gateway" "ocp_vpc_gateway" {
  count = var.publish_strategy == "Internal" ? 1 : 0
  name  = var.vpc_gateway_name == "" ? ibm_is_public_gateway.ocp_vpc_gateway[0].name : var.vpc_gateway_name
}