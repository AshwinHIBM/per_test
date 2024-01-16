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

variable "cos_bucket_location" {
  type        = string
  description = "The region in which to create the Cloud Object Store bucket. Used for the igntion file."
}

variable "cos_instance_location" {
  type        = string
  description = "Specifies whether the Cloud Object Store instance is global or in a specific region. Used for the ignition file."
}

variable "cos_storage_class" {
  type        = string
  description = "The storage class for the Cloud Object Store instance."
}

variable "cloud_instance_id" {
  type        = string
  description = "The Power VS Service Instance (aka Cloud Instance) ID."
}

variable "cluster_id" {
  type        = string
  description = "The ID created by the installer to uniquely identify the created cluster."
}

variable "enable_snat" {
  type        = bool
  description = "Indicates if the DHCP server will have SNAT enabled."
  default     = true
}

#variable "ignition" {
#  type        = string
#  description = "The ignition file."
#}

variable "image_bucket_file_name" {
  type        = string
  description = "File name of the image in the COS bucket."
}

variable "image_bucket_name" {
  type        = string
  description = "Name of the COS bucket containing the image to be imported."
}

variable "password_hash" {
  type = string
  description = "Hash of the bootstrap and cluster node password"
}

variable "resource_group" {
  type        = string
  description = "The name of the Power VS resource group to which the user belongs."
}

variable "workspace_id" {
    type = string
}