# Reusable module to dynamically attach private endpoints to any Azure resource
resource "azurerm_private_endpoint" "this" {
  name                = "pe-${var.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.target_subnet_id

  private_service_connection {
    name                           = "psc-${var.resource_name}"
    private_connection_resource_id = var.target_resource_id
    subresource_names              = [var.subresource_type] # e.g., "accountFqdn", "vault", "blob", "sites"
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "dns-group-${var.resource_name}"
    private_dns_zone_ids = [var.private_dns_zone_id]
  }
}