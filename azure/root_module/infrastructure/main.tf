module "network" {
  source              = "../../modules/networking"
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  spoke_cidr          = "10.240.0.0/16"
  subnet_configs      = var.subnet_configs
}

module "dns" {
  source              = "../../modules/dns_zones"
  resource_group_name = var.resource_group_name
  spoke_vnet_id       = module.network.spoke_vnet_id
  vnet_name           = module.network.spoke_vnet_name
  dns_zone_names      = [
    "privatelink.openai.azure.com",
    "privatelink.vaultcore.azure.net",
    "privatelink.documents.azure.com",
    "privatelink.blob.core.windows.net",
    "privatelink.azurecr.io"
  ]
}

module "hybrid_dns_resolution" {
  source                  = "../../modules/dns_resolver"
  environment             = var.environment
  location                = var.location
  resource_group_name     = var.resource_group_name
  spoke_vnet_id           = module.network.spoke_vnet_id
  dns_resolver_subnet_id  = module.network.subnet_ids["dns-inbound"]
}

module "network_security_groups" {
  for_each            = var.subnet_configs
  source              = "../../modules/nsgs"
  subnet_name         = each.key
  location            = var.location
  resource_group_name = var.resource_group_name
  target_subnet_id    = module.network.subnet_ids[each.key]
  
  # Grabs the structured array of security rules for this specific subnet from locals.tf
  # Uses try() to gracefully handle subnets that don't need custom rules (e.g., fallback to empty list)
  security_rules      = try(local.nsg_rule_matrix[each.key], [])
}

# 4. Enterprise Central Egress Hub Firewall Engine
module "central_firewall" {
  source                       = "../../modules/firewall"
  firewall_name                = "fw-hub-${var.environment}"
  location                     = var.location
  resource_group_name          = var.resource_group_name
  firewall_subnet_id           = module.network.hub_firewall_subnet_id
  sku_tier                     = "Premium"
  application_rule_collections = local.firewall_application_collections
  network_rule_collections     = local.firewall_network_collections
}