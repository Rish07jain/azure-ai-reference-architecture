environment         = "dev"
location            = "australiaeast"
resource_group_name = "rg-platformgpt-network-prod"
spoke_cidr          = "10.240.0.0/16"

subnet_configs = {
  "agents" = {
    cidr               = "10.240.1.0/24"
    is_delegated       = false
    delegation_service = null
  }
  "integration" = {
    cidr               = "10.240.2.0/24"
    is_delegated       = true
    delegation_service = "Microsoft.ApiManagement/service"
  }
  "compute" = {
    cidr               = "10.240.3.0/22"
    is_delegated       = false
    delegation_service = null
  }
  "data" = {
    cidr               = "10.240.7.0/24"
    is_delegated       = false
    delegation_service = null
  }
  "dns-inbound" = {
    cidr               = "10.240.8.0/26"
    is_delegated       = false
    delegation_service = null
  }
}

dns_zone_names = [
  "privatelink.openai.azure.com",
  "privatelink.vaultcore.azure.net",
  "privatelink.documents.azure.com",
  "privatelink.blob.core.windows.net",
  "privatelink.azurecr.io",
  "privatelink.australiaeast.azmaks.io"
]