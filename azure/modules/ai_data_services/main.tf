# 1. Key Vault with Zero Public Internet Access
resource "azurerm_key_vault" "kv" {
  name                          = "kv-platformgpt-${var.environment}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  tenant_id                     = var.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = var.public_access_flags["keyvault"] # Passed as FALSE from root tfvars
}

# 2. Azure AI Foundry / OpenAI Workspace Component
resource "azurerm_ai_foundry" "ai" {
  name                          = "ai-foundry-${var.environment}"
  location                      = var.location
  resource_group_name           = var.resource_group_name
  public_network_access_enabled = var.public_access_flags["ai_foundry"] # Passed as FALSE
}

# 3. Encapsulated Private Endpoint Creation for Key Vault inside this child module
resource "azurerm_private_endpoint" "kv_pe" {
  name                = "pe-keyvault"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.data_subnet_id

  private_service_connection {
    name                           = "psc-keyvault"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-group-kv"
    private_dns_zone_ids = [var.dns_zone_ids["privatelink.vaultcore.azure.net"]]
  }
}

# 4. Encapsulated Private Endpoint Creation for Azure AI Foundry
resource "azurerm_private_endpoint" "ai_pe" {
  name                = "pe-ai-foundry"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.data_subnet_id

  private_service_connection {
    name                           = "psc-ai-foundry"
    private_connection_resource_id = azurerm_ai_foundry.ai.id
    subresource_names              = ["accountFqdn"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "dns-group-ai"
    private_dns_zone_ids = [var.dns_zone_ids["privatelink.openai.azure.com"]]
  }
}