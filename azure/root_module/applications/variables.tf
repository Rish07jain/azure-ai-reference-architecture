variable "environment" {
  type        = string
  description = "Deployment target environment scope"
}

variable "location" {
  type        = string
  description = "Azure regional datacenter home"
}

variable "resource_group_name" {
  type        = string
  description = "Target workload Resource Group"
}

variable "tenant_id" {
  type        = string
  description = "Microsoft Entra ID Tenant Directory ID"
}

variable "public_access_flags" {
  type = map(bool)
  description = "Strict boolean toggles to deny public ingress routing across stateful clusters"
}

variable "enterprise_tags" {
  type        = map(string)
  description = "Resource metadata tagging matrix for governance compliance mapping"
}