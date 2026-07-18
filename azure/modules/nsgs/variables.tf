variable "subnet_name" {
  type        = string
  description = "Name of the subnet tier being protected"
}

variable "location" {
  type        = string
}

variable "resource_group_name" {
  type        = string
}

variable "target_subnet_id" {
  type        = string
  description = "The Azure Resource ID of the subnet to associate with this NSG"
}

variable "security_rules" {
  type = list(object({
    name        = string
    priority    = number
    direction   = string
    access      = string
    protocol    = string
    source      = string
    dest        = string
    dest_ports  = list(string) # Supports multiple destination ports professionally
  }))
  default     = []
  description = "Highly structured list of corporate network access rules"
}