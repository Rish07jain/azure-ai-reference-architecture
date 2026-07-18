resource "azurerm_api_management" "apim" {
  name                = "apim-gateway-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "Premium_1"
  virtual_network_type = "Internal"

  virtual_network_configuration {
    subnet_id = var.integration_subnet_id
  }
}

resource "azurerm_api_management_policy" "global" {
  api_management_id = azurerm_api_management.apim.id
  xml_content       = var.global_policy_xml
}

resource "azurerm_api_management_api_operation_policy" "operational_policy" {
  api_name            = "platformgpt-core-api"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name
  operation_id        = "chat-stream"
  xml_content       = var.operation_policy_xml
}