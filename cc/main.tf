resource "ibm_pi_cloud_connection" "new_cloud_connection" {
  pi_cloud_instance_id               = var.cloud_instance_id
  pi_cloud_connection_name           = "cloud-con-${var.cluster_id}"
  pi_cloud_connection_speed          = 50
  pi_cloud_connection_global_routing = true
  pi_cloud_connection_vpc_enabled    = true
  pi_cloud_connection_vpc_crns       = [var.vpc_crn]
}

data "ibm_pi_cloud_connection" "cloud_connection" {
  pi_cloud_connection_name = ibm_pi_cloud_connection.new_cloud_connection.pi_cloud_connection_name
  pi_cloud_instance_id     = var.cloud_instance_id
}