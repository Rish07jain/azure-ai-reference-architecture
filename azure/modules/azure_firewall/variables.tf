variable "firewall_name" {
  type        = string
  description = "The deployment name assigned to the central Azure Firewall instance"
}

variable "location" {
  type        = string
  description = "The target Azure region for the firewall infrastructure"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group container"
}

variable "firewall_subnet_id" {
  type        = string
  description = "The explicit Resource ID of AzureFirewallSubnet inside the Hub VNet"
}

variable "sku_tier" {
  type        = string
  default     = "Premium"
  description = "The SKU tier for the firewall instance (Standard or Premium)"
}

variable "application_rule_collections" {
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses  = list(string)
      destination_fqdns = list(string)
      protocols = list(object({
        type = string
        port = number
      }))
    }))
  }))
  default     = {}
  description = "A deeply structured map of FQDN-based application filtering rules passed from locals"
}

variable "network_rule_collections" {
  type = map(object({
    priority = number
    action   = string
    rules = map(object({
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
      protocols             = list(string) # TCP, UDP, ICMP, Any
    }))
  }))
  default     = {}
  description = "A deeply structured map of IP/Port-based network layer protocol rules passed from locals"
}