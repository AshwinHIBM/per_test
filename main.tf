terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.56.1"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "~> 2.1.0"
    }
  }
  required_version = ">= 1.0.0"
}
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
  region           = "dal"
  zone             = var.ibmcloud_zone
}

#module "vpc" {
#  source = "./vpc"


#  cluster_id           = var.cluster_id
#  publish_strategy     = var.powervs_publish_strategy
#  resource_group       = var.powervs_resource_group
#  vpc_zone             = var.powervs_vpc_zone
 # vpc_subnet_name      = var.powervs_vpc_subnet_name
 # vpc_name             = var.powervs_vpc_name
 # vpc_gateway_name     = var.powervs_vpc_gateway_name
 # vpc_gateway_attached = var.powervs_vpc_gateway_attached
 # wait_for_vpc         = var.powervs_wait_for_vpc
#}

module "lb" {
  source = "./lb"

  cluster_id     = var.cluster_id
  resource_group = var.powervs_resource_group
  vpc_id         = var.vpc_id
  vpc_subnet_id  = var.vpc_subnet_id
}