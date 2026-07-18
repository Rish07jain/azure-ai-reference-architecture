# Provisions the Spoke VNet with isolated subnets for each architectural tier
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-${var.environment}"
  address_space       = [var.spoke_cidr]
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_subnet" "tiers" {
  for_each             = var.subnet_configs
  name                 = "snet-${each.key}"
  virtual_network_name = azurerm_virtual_network.spoke.name
  resource_group_name  = var.resource_group_name
  address_prefixes     = [each.value.cidr]
  
  # Delegation blocks for services like APIM / App Service if required
  dynamic "delegation" {
    for_each = each.value.is_delegated ? [1] : []
    content {
      name = "service-delegation"
      service_delegation {
        name = each.value.delegation_service
      }
    }
  }
}

# Azure DNS Private Resolver inside the designated DNS inbound subnet for VPN users
resource "azurerm_private_dns_resolver" "vpn_resolver" {
  name                = "dns-resolver-vpn"
  location            = var.location
  resource_group_name = var.resource_group_name
  virtual_network_id  = azurerm_virtual_network.spoke.id
}

resource "azurerm_private_dns_resolver_inbound_endpoint" "inbound" {
  name                    = "vpn-dns-inbound"
  private_dns_resolver_id = azurerm_private_dns_resolver.vpn_resolver.id
  location                = var.location
  ip_configurations {
    subnet_id = azurerm_subnet.tiers["dns-inbound"].id
  }
}