variable "ibmcloud_api_key" {
  default = ""
}
variable "ibmcloud_region" {
  default = "osa"
}
variable "ibmcloud_zone" {
  default = "osa21"
}

variable "cluster_id" {
  type        = string
  description = "The ID created by the installer to uniquely identify the created cluster."
}

variable "cloud_instance_id" {
  type        = string
  description = "The Power VS Service Instance (aka Cloud Instance) ID."
}

variable "vpc_crn" {
  type        = string
  description = "The CRN of the IBM Cloud VPC."
}


variable "dns_server" {
  type        = string
  description = "The desired DNS server for the DHCP instance to server."
  default     = "1.1.1.1"
}

variable "enable_snat" {
  type        = bool
  description = "Boolean indicating if SNAT should be enabled."
  default     = true
}