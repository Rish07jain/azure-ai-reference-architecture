variable "environment" {
  type        = string
  description = "Target deployment environment tier (dev, uat, prod)"
}

variable "location" {
  type        = string
  description = "The target Azure region for VNet placement"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group hosting the network resources"
}

variable "spoke_cidr" {
  type        = string
  description = "The primary CIDR block address space for the Spoke VNet"
}

variable "subnet_configs" {
  type = map(object({
    cidr               = string
    is_delegated       = bool
    delegation_service = string
  }))
  description = "A configuration matrix outlining names, CIDRs, and service delegation targets for each subnet tier"
}