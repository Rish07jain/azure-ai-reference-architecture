# Loop through all required enterprise Private DNS Zones
resource "azurerm_private_dns_zone" "zones" {
  for_each            = toset(var.dns_zone_names) # e.g., privatelink.openai.azure.com, privatelink.vaultcore.azure.net
  name                = each.key
  resource_group_name = var.resource_group_name
}

# Link every created Private DNS Zone automatically back to the Spoke VNet
resource "azurerm_private_dns_zone_virtual_network_link" "spoke_links" {
  for_each              = azurerm_private_dns_zone.zones
  name                  = "link-to-${var.vnet_name}"
  private_dns_zone_name = each.value.name
  virtual_network_id    = var.spoke_vnet_id
  resource_group_name   = var.resource_group_name
}