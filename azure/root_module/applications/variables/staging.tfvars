environment         = "stag"
location            = "australiaeast"
resource_group_name = "rg-platformgpt-apps-stag"
tenant_id           = "44c52086-6b2a-43cf-b5f7-9c98a5dc87fc"

# Explicitly forcing network firewalls to drop all traffic that doesn't originate from VNet endpoints
public_access_flags = {
  keyvault     = false
  ai_foundry   = false
  cosmos_db    = false
  storage_acct = false
  acr          = false
}

enterprise_tags = {
  BusinessUnit = "Legal Operations"
  Application  = "PlatformGPT"
  CostCenter   = "AU-9901-AI"
  ManagedBy    = "CloudOps DevOps Team"
  Criticality  = "Tier-1-Enterprise"
}