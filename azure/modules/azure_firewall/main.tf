resource "azurerm_public_ip" "fw_pip" {
  name                = "pip-${var.firewall_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "this" {
  name                = var.firewall_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = var.sku_tier

  ip_configuration {
    name                 = "fw-ip-config"
    subnet_id            = var.firewall_subnet_id
    public_ip_address_id = azurerm_public_ip.fw_pip.id
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "app_rules" {
  name               = "${var.firewall_name}-policy-group"
  firewall_policy_id = azurerm_firewall.this.firewall_policy_id
  priority           = 100

  dynamic "application_rule_collection" {
    for_each = var.egress_application_rules
    content {
      name     = application_rule_collection.key
      priority = application_rule_collection.value.priority
      action   = "Allow"

      dynamic "rule" {
        for_each = application_rule_collection.value.rules
        content {
          name             = rule.key
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.destination_fqdns
          protocols {
            type = rule.value.protocol_type
            port = rule.value.protocol_port
          }
        }
      }
    }
  }
}