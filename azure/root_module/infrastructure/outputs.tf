output "spoke_vnet_id" {
  value       = module.network.spoke_vnet_id
  description = "Resource ID of the Spoke Virtual Network"
}

output "subnet_ids" {
  value = {
    agents      = module.network.subnet_ids["agents"]
    integration = module.network.subnet_ids["integration"]
    compute     = module.network.subnet_ids["compute"]
    data        = module.network.subnet_ids["data"]
  }
  description = "Map of all generated subnet Resource IDs"
}

output "private_dns_zone_ids" {
  value       = module.dns.private_dns_zone_ids
  description = "Map of Zone Names to their respective Azure Resource IDs for remote state referencing"
}