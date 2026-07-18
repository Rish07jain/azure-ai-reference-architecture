variable "environment" {
  type        = string
  description = "Target deployment environment boundary"
}

variable "location" {
  type        = string
  description = "Azure region mapping home for stateful platform instances"
}

variable "resource_group_name" {
  type        = string
  description = "The resource group container name"
}

variable "tenant_id" {
  type        = string
  description = "The Entra ID Tenant ID utilized for secure Key Vault control plane assignments"
}

variable "public_access_flags" {
  type        = map(bool)
  description = "A mapping configuration of public network access states, explicitly toggled to FALSE for enterprise compliance"
}   