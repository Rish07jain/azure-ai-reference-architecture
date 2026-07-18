variable "environment" {
  type        = string
  description = "Target environment scope string"
}

variable "location" {
  type        = string
  description = "Azure regional location deployment home for the compute node pools"
}

variable "resource_group_name" {
  type        = string
  description = "Target resource group container name"
}

variable "compute_subnet_id" {
  type        = string
  description = "The specific isolated network Subnet ID where the AKS worker nodes and pods will be attached"
}