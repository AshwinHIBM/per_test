variable "ibmcloud_api_key" {
  default = ""
}
variable "ibmcloud_region" {
  default = "dal"
}
variable "ibmcloud_zone" {
  default = "dal10"
}
variable "system_type" {
  default = "s922"
}
variable "vm_prefix" {
  default = ""
}
variable "service_instance_id" {
  default = ""
}
variable "dhcp_id" {
  default = ""
}
variable "rhcos_count" {
  default = 1
}
variable "rhcos_image_name" {
  default = ""
}
variable "keypair_name" {
  default = ""
}
variable "password_hash" {
  default = ""
}

variable "cloud_instance_id" {
  type        = string
  description = "The Power VS Service Instance (aka Cloud Instance) ID."
}