variable "resource_name" {
  type        = string
  description = "The baseline name of the target resource used to build standardized endpoint metadata names"
}

variable "location" {
  type        = string
  description = "The Azure region where the private endpoint interface will be provisioned"
}

variable "resource_group_name" {
  type        = string
  description = "The target resource group name"
}

variable "target_subnet_id" {
  type        = string
  description = "The specific Subnet ID where the Private Endpoint's Network Interface (NIC) will reside"
}

variable "target_resource_id" {
  type        = string
  description = "The full Azure Resource ID of the backend PaaS service being targeted (e.g., Key Vault ID)"
}

variable "subresource_type" {
  type        = string
  description = "The target service's subresource type mapping string (e.g., 'vault', 'blob', 'accountFqdn')"
}

variable "private_dns_zone_id" {
  type        = string
  description = "The Resource ID of the pre-provisioned Private DNS Zone to automatically register this endpoint interface to"
}