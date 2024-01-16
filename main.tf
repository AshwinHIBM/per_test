provider "ibm" {
  alias            = "vpc"
  ibmcloud_api_key = var.powervs_api_key
  region           = var.vpc_region
  zone             = var.vpc_zone
}

provider "ibm" {
   alias            = "powervs"
   ibmcloud_api_key = var.powervs_api_key
   region           = var.powervs_region
   zone             = var.powervs_zone
}

module "dhcp" {
  providers = {
    ibm = ibm.powervs
  }
  source = "./dhcp"
  cluster_id             = var.cluster_id
  dns_server             = var.powervs_dns_server
  machine_cidr           = var.powervs_machine_cidr
  workspace_id           = module.workspace.pi_workspace_id
}

#module "load_balancer" {
#  providers = {
#    ibm = ibm.vpc
#  }
# source = "./lb"
#  bootstrap_ip         = module.vm.bootstrap_ip
#  cluster_id           = var.cluster_id
#  ips                  = toset([module.vm.bootstrap_ip,module.vm.clusternode_ip])
#  resource_group       = var.powervs_resource_group
#  service_instance_crn = module.workspace.pi_workspace_id
#  vpc_crn              = module.vpc.workspace_crn
#  vpc_id               = var.powervs_vpc_id
#  vpc_region           = var.vpc_region
#  vpc_subnet_id        = module.vpc.vpc_subnet_id
#}

module "transit_gateway" {
  providers = {
    ibm = ibm.vpc
  }
  source = "./transit_gateway"
  cluster_id               = var.cluster_id
  resource_group           = var.powervs_resource_group
  workspace_crn            = module.workspace.pi_workspace_crn
  vpc_crn                  = module.vpc.vpc_crn
  vpc_region               = var.vpc_region
}

module "vpc" {
  providers = {
    ibm = ibm.vpc
  }
  source = "./vpc"
  cluster_id       = var.cluster_id
  resource_group   = var.powervs_resource_group
  vpc_zone         = var.vpc_zone 
}

module "vm" {
  providers = {
    ibm = ibm.powervs
  }
  source = "./vm"
  cloud_instance_id      = module.workspace.pi_workspace_id
  cluster_id             = var.cluster_id
  cos_bucket_location    = var.powervs_image_cos_bucket_location
  cos_instance_location  = var.powervs_cos_instance_location
  dhcp_id                = module.dhcp.dhcp_id
  image_bucket_file_name = var.powervs_image_bucket_file_name
  keypair_name           = var.powervs_keypair_name
  image_bucket_name      = var.powervs_image_bucket_name
  password_hash          = var.powervs_password_hash
  resource_group         = var.powervs_resource_group
  workspace_id           = module.workspace.pi_workspace_id
}

module "workspace" {
  providers = {
    ibm = ibm.powervs
  }
  source = "./workspace"
  cluster_id     = var.cluster_id
  resource_group = var.powervs_resource_group
  zone           = var.powervs_zone
}