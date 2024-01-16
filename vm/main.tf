terraform {
 required_providers {
    ibm = {
      source  = "ibm-cloud/ibm"
      version = "1.60.0"
    }
    ignition = {
      source  = "community-terraform-providers/ignition"
      version = "~> 2.1.0"
    }
  }
  required_version = ">= 1.0.0"
}

resource "random_id" "label" {
  byte_length = "2" # Since we use the hex, the word length would double
  prefix      = "${var.vm_prefix}-"
}

locals {
  vm_id = random_id.label.hex
}

data "ignition_user" "vm_user" {
  name                = "core"
  password_hash       = var.password_hash
}

#data "ignition_file" "clusternode_ignition" {
#  count     = var.rhcos_count
#  overwrite = true
#  mode      = "420" // 0644
#  path      = "/etc/hostname"
#  content {
#    source {
#      source = var.
#    }
#  }
#}

#data "ignition_config" "vm_ignition" {
#  count = var.rhcos_count
#  users = [data.ignition_user.vm_user.rendered]
#  files = [data.ignition_file.clusternode_ignition.rendered]
#}

#data "ignition_config" "clusternode_ignition" {
#  count = var.rhcos_count
#  users = [data.ignition_user.vm_user.rendered]
#}

resource "ibm_pi_image" "boot_image" {
  pi_image_name             = "rhcos-${var.cluster_id}"
  pi_cloud_instance_id      = var.workspace_id
  pi_image_bucket_name      = var.image_bucket_name
  pi_image_bucket_access    = "public"
  pi_image_bucket_region    = var.cos_bucket_location
  pi_image_bucket_file_name = var.image_bucket_file_name
  pi_image_storage_type     = "tier1"
}

data "ibm_pi_dhcp" "dhcp_service" {
  pi_cloud_instance_id    = var.workspace_id
  pi_dhcp_id              = var.dhcp_id
}

data "ibm_pi_key" "key" {
  pi_cloud_instance_id = var.workspace_id
  pi_key_name          = var.keypair_name
}

data "ibm_resource_group" "cos_group" {
  name = var.resource_group
}

resource "ibm_resource_instance" "cos_instance" {
  name              = "${var.cluster_id}-cos"
  resource_group_id = data.ibm_resource_group.cos_group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = var.cos_instance_location
  tags              = [var.cluster_id]
}

# Create an IBM COS Bucket to store ignition
resource "ibm_cos_bucket" "ignition" {
  bucket_name          = "${var.cluster_id}-bootstrap-ign"
  resource_instance_id = ibm_resource_instance.cos_instance.id
  region_location      = var.cos_bucket_location
  storage_class        = var.cos_storage_class
}

resource "ibm_resource_key" "cos_service_cred" {
   name                 = "${var.cluster_id}-cred"
   role                 = "Reader"
   resource_instance_id = ibm_resource_instance.cos_instance.id
   parameters           = { HMAC = true }
}

# Place the bootstrap ignition file in the ignition COS bucket
resource "ibm_cos_bucket_object" "ignition" {
  bucket_crn      = ibm_cos_bucket.ignition.crn
  bucket_location = ibm_cos_bucket.ignition.region_location
  content_file    = "${path.module}/ignition/master.ign"
  key             = "master.ign"
  etag            = md5("${path.module}/ignition/master.ign")
}

data "ibm_iam_auth_token" "iam_token" {}

resource "ibm_pi_instance" "bootstrap" {
  count                = 1
  pi_memory            = "2"
  pi_processors        = "0.25"
  pi_instance_name     = "${local.vm_id}-rhcos-bootstrap1"
  pi_proc_type         = "shared"
  pi_image_id          = ibm_pi_image.boot_image.image_id
  pi_key_pair_name     = data.ibm_pi_key.key.id
  pi_sys_type          = var.system_type
  pi_cloud_instance_id = var.service_instance_id
  pi_health_status     = "WARNING"
  pi_network {
    network_id = data.ibm_pi_dhcp.dhcp_service.network_id
  }
  pi_user_data = base64encode(templatefile("${path.module}/template/clusternode_fetch.ign", {
    PROTOCOL    = "https"
    HOSTNAME    = ibm_cos_bucket.ignition.s3_endpoint_public
    BUCKET_NAME = ibm_cos_bucket.ignition.bucket_name
    OBJECT_NAME = ibm_cos_bucket_object.ignition.key
    IAM_TOKEN   = data.ibm_iam_auth_token.iam_token.iam_access_token
  }))

}

resource "ibm_pi_instance" "cluster_node" {
  count                = 1
  pi_memory            = "2"
  pi_processors        = "0.25"
  pi_instance_name     = "${local.vm_id}-rhcos-master1"
  pi_proc_type         = "shared"
  pi_image_id          = ibm_pi_image.boot_image.image_id
  pi_key_pair_name     = data.ibm_pi_key.key.id
  pi_sys_type          = var.system_type
  pi_cloud_instance_id = var.service_instance_id
  pi_health_status     = "WARNING"
  pi_network {
    network_id = data.ibm_pi_dhcp.dhcp_service.network_id
  }
  #pi_user_data         = base64encode(data.ignition_config.clusternode_ignition[count.index].rendered)
}
resource "time_sleep" "wait_for_bootstrap_macs" {
  create_duration = "3m"

  depends_on = [ibm_pi_instance.bootstrap]
}

locals {
  bootstrap_ips   = [for lease in data.ibm_pi_dhcp.dhcp_service_refresh.leases : lease.instance_ip if ibm_pi_instance.bootstrap[0].pi_network[0].mac_address == lease.instance_mac]
  clusternode_ips = [for lease in data.ibm_pi_dhcp.dhcp_service_refresh.leases : lease.instance_ip if ibm_pi_instance.cluster_node[0].pi_network[0].mac_address == lease.instance_mac]
}

data "ibm_pi_dhcp" "dhcp_service_refresh" {
  depends_on           = [time_sleep.wait_for_bootstrap_macs]
  pi_cloud_instance_id = var.cloud_instance_id
  pi_dhcp_id           = var.dhcp_id
}