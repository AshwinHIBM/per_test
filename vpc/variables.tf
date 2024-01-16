variable "cluster_id" {
  type        = string
  description = "The ID created by the installer to uniquely identify the created cluster."
}

variable "publish_strategy" {
  type        = string
  description = "Publishing strategy used by cluster. Internal or External"
  default     = "External"
}

variable "resource_group" {
  type        = string
  description = "The name of the Power VS resource group to which the user belongs."
}

variable "vpc_zone" {
  type        = string
  description = "The IBM Cloud zone in which the VPC is created."
}

variable "wait_for_vpc" {
  type        = string
  description = "The seconds wait for VPC creation, default is 60s."
  default     = "60s"
}

variable "vpc_gateway_name" {
  type        = string
  description = "The name of an existing VPC gateway"
  default     = ""
}