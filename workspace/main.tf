terraform {
  required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.60.0"
    }
  }
  required_version = ">= 1.0.0"
}

data "ibm_resource_group" "group" {
  name = var.resource_group
}

resource "ibm_pi_workspace" "workspace" {
  pi_datacenter        = var.zone
  pi_name              = "${var.cluster_id}-power-iaas"
  pi_plan              = "public"
  pi_resource_group_id = data.ibm_resource_group.group.id
}

data "ibm_pi_workspace" "workspace_data" {
  pi_cloud_instance_id = resource.ibm_pi_workspace.workspace.id
}