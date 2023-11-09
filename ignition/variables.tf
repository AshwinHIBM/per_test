variable "ibmcloud_api_key" {
  default = ""
}
variable "ibmcloud_region" {
  default = "dal"
}
variable "ibmcloud_zone" {
  default = "dal10"
}

variable "dhcp_id" {
  default = ""
}

variable "rhcos_image_name" {
  default = ""
}

variable "rhcos_count" {
  default = 1
}

variable "vm_prefix" {
  default = ""
}