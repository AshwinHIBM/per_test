resource "random_id" "label" {
  byte_length = "2" # Since we use the hex, the word length would double
  prefix      = "${var.vm_prefix}-"
}

locals {
  vm_id = random_id.label.hex
}

data "ignition_user" "vm_user" {
  name                = "core"
  password_hash = var.password_hash
}

data "ignition_file" "vm_hostname" {
  count     = var.rhcos_count
  overwrite = true
  mode      = "420" // 0644
  path      = "/etc/hostname"
  content {
    content = <<EOF
${local.vm_id}-rhcos-${count.index}
EOF
  }
}

data "ignition_config" "vm_ignition" {
  count = var.rhcos_count
  users = [data.ignition_user.vm_user.rendered]
  files = [data.ignition_file.vm_hostname[count.index].rendered]
}

data "ibm_pi_image" "rhcos_image" {
  pi_image_name        = var.rhcos_image_name
  pi_cloud_instance_id = var.service_instance_id
}

data "ibm_pi_dhcp" "dhcp_service" {
  pi_cloud_instance_id    = var.service_instance_id
  pi_dhcp_id              = var.dhcp_id
}
data "ibm_pi_key" "key" {
  pi_cloud_instance_id = var.service_instance_id
  pi_key_name          = var.keypair_name
}
resource "ibm_pi_instance" "bootstrap" {
  count                = 1
  pi_memory            = "2"
  pi_processors        = "0.25"
  pi_instance_name     = "${local.vm_id}-rhcos-bootstrap"
  pi_proc_type         = "shared"
  pi_image_id          = data.ibm_pi_image.rhcos_image.id
  pi_storage_pool      = data.ibm_pi_image.rhcos_image.storage_pool
  pi_key_pair_name     = data.ibm_pi_key.key.id
  pi_sys_type          = var.system_type
  pi_cloud_instance_id = var.service_instance_id
  pi_health_status     = "WARNING"
  pi_network {
    network_id = data.ibm_pi_dhcp.dhcp_service.network_id
  }
  pi_user_data         = base64encode(data.ignition_config.vm_ignition[count.index].rendered)

}

resource "ibm_pi_instance" "cluster_node" {
  count                = 1
  pi_memory            = "2"
  pi_processors        = "0.25"
  pi_instance_name     = "${local.vm_id}-rhcos-master"
  pi_proc_type         = "shared"
  pi_image_id          = data.ibm_pi_image.rhcos_image.id
  pi_storage_pool      = data.ibm_pi_image.rhcos_image.storage_pool
  pi_key_pair_name     = data.ibm_pi_key.key.id
  pi_sys_type          = var.system_type
  pi_cloud_instance_id = var.service_instance_id
  pi_health_status     = "WARNING"
  pi_network {
    network_id = data.ibm_pi_dhcp.dhcp_service.network_id
  }
}