variable "cluster_id" {
  type        = string
  description = "The ID created by the installer to uniquely identify the created cluster."
}
variable "powervs_publish_strategy" {
  type        = string
  description = "The cluster publishing strategy, either Internal or External"
  default     = "External"
}
variable "powervs_resource_group" {
  type        = string
  description = "The cloud instance resource group"
}
variable "powervs_vpc_zone" {
  type        = string
  description = "The IBM Cloud zone associated with the VPC region you're using"
}
variable "powervs_vpc_subnet_name" {
  type        = string
  description = "The name of a pre-created IBM Cloud Subnet. Must be in $powervs_vpc_region"
  default     = ""
}
variable "powervs_vpc_name" {
  type        = string
  description = "The name of a pre-created IBM Cloud VPC. Must be in $powervs_vpc_region"
  default     = ""
}
variable "powervs_vpc_gateway_attached" {
  type        = bool
  description = "Specifies whether an existing gateway is already attached to an existing VPC."
  default     = false
}

variable "powervs_vpc_gateway_name" {
  type        = string
  description = "The name of a pre-created VPC gateway. Must be in $powervs_vpc_region"
  default     = ""
}
variable "powervs_wait_for_vpc" {
  type        = string
  description = "The seconds wait for VPC creation, default is 60s"
  default     = "60s"
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
variable "vpc_id" {
  type        = string
  description = "The ID of the VPC."
}

variable "vpc_subnet_id" {
  type        = string
  description = "The ID of the VPC subnet."
}