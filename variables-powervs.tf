variable "cluster_id" {
  type        = string
  description = "The ID created by the installer to uniquely identify the created cluster."
}

variable "powervs_api_key" {
  default = ""
}

variable "powervs_dns_server" {
  type        = string
  description = "The desired DNS server for the DHCP instance to server."
  default     = "1.1.1.1"
}

variable "powervs_image_bucket_name" {
  type        = string
  description = "Name of the COS bucket containing the image to be imported."
}

variable "powervs_image_cos_bucket_location" {
  type        = string
  description = "The region in which to create the Cloud Object Store bucket. Used for the igntion file."
}

variable "powervs_machine_cidr" {
  type        = string
  description = "The machine network (IPv4 only)"
}

variable "powervs_region" {
  default = "dal"
}

variable "powervs_password_hash" {
  type = string
  description = "Hash of the bootstrap and cluster node password"
}

variable "powervs_resource_group" {
  type        = string
  description = "The cloud instance resource group"
}

variable "powervs_vpc_name" {
  type        = string
  description = "The name of a pre-created VPC."
  default     = ""
}

variable "powervs_zone" {
  type    = string
  default = "dal10"
}

variable "vpc_region" {
  type        = string
  description = "Region of a VPC connection to the transit gateway"
}

variable "subnet_id" {
  type        = string
  description = "The ID of the VPC subnet."
}

variable "vpc_zone" {
  type        = string
  description = "Zone"
}