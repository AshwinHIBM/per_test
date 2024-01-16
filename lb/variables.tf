variable "cluster_id" {
  type        = string
  description = "The ID created by the installer to uniquely identify the created cluster."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "subnet_id" {
  type        = string
  description = "The ID of the VPC subnet."
}

variable "resource_group" {
  type        = string
  description = "The name of the Power VS resource group to which the user belongs."
}

variable "ibmcloud_api_key" {
  default = ""
}
variable "ibmcloud_region" {
  default = "dal"
}
variable "ibmcloud_zone" {
  default = "dal10"
}
#variable "lb_int_id" { type = string }
#variable "lb_ext_id" { type = string }
#variable "machine_cfg_pool_id" { type = string }
#variable "api_pool_int_id" { type = string }
#variable "api_pool_ext_id" { type = string }
variable "ips" { default = [] }
variable "bootstrap_ip" {
  type        = string
  description = "The IP address of the bootstrap node."
}
