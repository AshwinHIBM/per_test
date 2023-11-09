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
  region           = "us-south"
  zone             = var.ibmcloud_zone
}

locals {
  tcp_ports = [22623, 80, 22]
  api_servers       = var.ips
  api_servers_count = length(local.api_servers)
}
data "ibm_resource_group" "resource_group" {
  name = var.resource_group
}
resource "ibm_is_security_group" "ocp_security_group" {
  name           = "${var.cluster_id}-ocp-sec-group2"
  resource_group = data.ibm_resource_group.resource_group.id
  vpc            = var.vpc_id
  tags           = [var.cluster_id]
}

resource "ibm_is_security_group_rule" "inbound_ports" {
  count     = length(local.tcp_ports)
  group     = ibm_is_security_group.ocp_security_group.id
  direction = "inbound"
  tcp {
    port_min = local.tcp_ports[count.index]
    port_max = local.tcp_ports[count.index]
  }
}

resource "ibm_is_security_group_rule" "outbound_any" {
  group     = ibm_is_security_group.ocp_security_group.id
  direction = "outbound"
}

resource "ibm_is_lb" "load_balancer" {
  name            = "${var.cluster_id}-loadbalancer"
  resource_group  = data.ibm_resource_group.resource_group.id
  subnets         = [var.vpc_subnet_id]
  security_groups = [ibm_is_security_group.ocp_security_group.id]
  tags            = [var.cluster_id, "${var.cluster_id}-loadbalancer"]
  type            = "public"
}

resource "ibm_is_lb" "load_balancer_int" {
  name            = "${var.cluster_id}-loadbalancer-int"
  resource_group  = data.ibm_resource_group.resource_group.id
  subnets         = [var.vpc_subnet_id]
  security_groups = [ibm_is_security_group.ocp_security_group.id]
  tags            = [var.cluster_id, "${var.cluster_id}-loadbalancer-int"]
  type            = "private"
}

# machine-config backend pool and listener
resource "ibm_is_lb_pool" "machine_config_pool" {
  depends_on = [ibm_is_lb.load_balancer_int]

  name           = "machine-config-server"
  lb             = ibm_is_lb.load_balancer_int.id
  algorithm      = "round_robin"
  protocol       = "tcp"
  health_delay   = 60
  health_retries = 5
  health_timeout = 30
  health_type    = "tcp"
}

resource "ibm_is_lb_listener" "machine_config_listener" {
  lb           = ibm_is_lb.load_balancer_int.id
  port         = 22623
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.machine_config_pool.id
}

# external api backend pool and listener
resource "ibm_is_lb_pool" "api_pool" {
  depends_on = [ibm_is_lb.load_balancer]

  name           = "openshift-api-server"
  lb             = ibm_is_lb.load_balancer.id
  algorithm      = "round_robin"
  protocol       = "tcp"
  health_delay   = 60
  health_retries = 5
  health_timeout = 30
  health_type    = "tcp"
}

resource "ibm_is_lb_listener" "api_listener" {
  lb           = ibm_is_lb.load_balancer.id
  port         = 80
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.api_pool.id
}

# internal api backend pool and listener
resource "ibm_is_lb_pool" "api_pool_int" {
  depends_on = [ibm_is_lb.load_balancer_int]

  name           = "openshift-api-server"
  lb             = ibm_is_lb.load_balancer_int.id
  algorithm      = "round_robin"
  protocol       = "tcp"
  health_delay   = 60
  health_retries = 5
  health_timeout = 30
  health_type    = "tcp"
}

resource "ibm_is_lb_listener" "api_listener_int" {
  lb           = ibm_is_lb.load_balancer_int.id
  port         = 80
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.api_pool_int.id
}

resource "ibm_is_lb_pool_member" "api_member_int" {
  count          = local.api_servers_count
  depends_on     = [ibm_is_lb_pool_member.machine_config_member]
  lb             = ibm_is_lb.load_balancer_int.id
  pool           = ibm_is_lb_pool.api_pool_int.id
  port           = 80
  target_address = local.api_servers[count.index]
}

resource "ibm_is_lb_pool_member" "machine_config_member" {
  count          = local.api_servers_count
  lb             = ibm_is_lb.load_balancer_int.id
  pool           = ibm_is_lb_pool.machine_config_pool.id
  port           = 22623
  target_address = local.api_servers[count.index]
}
resource "ibm_is_lb_pool_member" "api_member" {
  count          = local.api_servers_count
  lb             = ibm_is_lb.load_balancer.id
  pool           = ibm_is_lb_pool.api_pool.id
  port           = 80
  target_address = local.api_servers[count.index]
}

resource "ibm_is_lb_pool" "bootstrap_pool" {
  name           = "bootstrap-node"
  lb             = ibm_is_lb.load_balancer.id
  algorithm      = "round_robin"
  protocol       = "tcp"
  health_delay   = 5
  health_retries = 2
  health_timeout = 2
  health_type    = "tcp"
}


resource "ibm_is_lb_listener" "bootstrap_listener" {
  lb           = ibm_is_lb.load_balancer.id
  port         = 22
  protocol     = "tcp"
  default_pool = ibm_is_lb_pool.bootstrap_pool.id
}

# explicit depends because the LB will be in `UPDATE_PENDING` state and this will fail
resource "ibm_is_lb_pool_member" "bootstrap" {
  depends_on     = [ibm_is_lb_listener.bootstrap_listener]
  lb             = ibm_is_lb.load_balancer.id
  pool           = ibm_is_lb_pool.bootstrap_pool.id
  port           = 22
  target_address = var.bootstrap_ip
}