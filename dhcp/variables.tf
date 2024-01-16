variable "cluster_id" {
  type        = string
  description = "The ID created by the installer to uniquely identify the created cluster."
}

variable "dns_server" {
  type        = string
  description = "The desired DNS server for the DHCP instance to server."
  default     = "1.1.1.1"
}

variable "machine_cidr" {
  type        = string
  description = "The machine network (IPv4 only)"
}

variable "workspace_id" {
  type        = string
  description = "The Power VS Service Instance (aka Cloud Instance) ID."
}