variable "cluster_id" {
  type        = string
  description = "The ID created by the installer to uniquely identify the created cluster."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "vpc_subnet_id" {
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
  default = "osa"
}
variable "ibmcloud_zone" {
  default = "osa21"
}