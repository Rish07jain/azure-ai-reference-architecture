variable "environment" {
  type        = string
  description = "Deployment environment name (dev, uat, prod)"
}

variable "location" {
  type        = string
  description = "Azure Region for core infrastructure"
}

variable "resource_group_name" {
  type        = string
  description = "Target Resource Group name"
}

variable "spoke_cidr" {
  type        = string
  description = "The primary CIDR block for the Spoke VNet"
}

variable "subnet_configs" {
  type = map(object({
    cidr                = string
    is_delegated        = bool
    delegation_service  = string
  }))
  description = "Configuration matrix for network subnets"
}

variable "dns_zone_names" {
  type        = list(string)
  description = "List of private endpoints domains to provision zones for"
}