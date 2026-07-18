variable "resource_group_name" {
  type        = string
  description = "The resource group where the DNS zones will be centralized"
}

variable "spoke_vnet_id" {
  type        = string
  description = "The Azure Resource ID of the Spoke VNet to link the DNS zones against"
}

variable "vnet_name" {
  type        = string
  description = "The friendly name of the Spoke VNet utilized for resource naming consistency"
}

variable "dns_zone_names" {
  type        = list(string)
  description = "A list of target Private Link FQDN domains to generate (e.g., privatelink.openai.azure.com)"
}