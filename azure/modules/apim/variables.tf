variable "environment" {
  type        = string
  description = "Target environment string"
}

variable "location" {
  type        = string
  description = "Azure region location for the gateway node deployments"
}

variable "resource_group_name" {
  type        = string
  description = "The name of the target resource group container"
}

variable "integration_subnet_id" {
  type        = string
  description = "The specific delegated integration Subnet ID where the Premium APIM internal cluster nodes will inject"
}

variable "tenant_id" {
  type        = string
  description = "The Entra ID directory string used within APIM XML validation policy structures"
}