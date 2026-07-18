data "terraform_remote_state" "infra" {
  backend = "azurerm"
  config = {
    storage_account_name = "sttfstatecommon"
    container_name       = "infrastructure-state"
    key                  = "${var.environment}.terraform.tfstate"
  }
}

# 1. Stateful Base Data Plane
module "ai_data_services" {
  source              = "../../modules/ai_data_services"
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = var.tenant_id
  public_access_flags = var.public_access_flags
}

# 2. Key Vault Private Endpoint Injection via Shared Module
module "pe_keyvault" {
  source                 = "../../modules/private_endpoint"
  resource_name          = "keyvault"
  location               = var.location
  resource_group_name    = var.resource_group_name
  target_subnet_id       = data.terraform_remote_state.infra.outputs.subnet_ids["data"]
  target_resource_id     = module.ai_data_services.keyvault_id
  subresource_type       = "vault"
  private_dns_zone_id    = data.terraform_remote_state.infra.outputs.private_dns_zone_ids["privatelink.vaultcore.azure.net"]
}

# 3. Azure AI Foundry Private Endpoint Injection via Shared Module
module "pe_ai_foundry" {
  source                 = "../../modules/private_endpoint"
  resource_name          = "ai-foundry"
  location               = var.location
  resource_group_name    = var.resource_group_name
  target_subnet_id       = data.terraform_remote_state.infra.outputs.subnet_ids["data"]
  target_resource_id     = module.ai_data_services.ai_foundry_id
  subresource_type       = "accountFqdn"
  private_dns_zone_id    = data.terraform_remote_state.infra.outputs.private_dns_zone_ids["privatelink.openai.azure.com"]
}

# 4. Compute Engine Tier (AKS / App Services)
module "compute_plane" {
  source              = "../../modules/aks"
  environment         = var.environment
  location            = var.location
  resource_group_name = var.resource_group_name
  compute_subnet_id   = data.terraform_remote_state.infra.outputs.subnet_ids["compute"]
}

# 5. Core Ingress / API Routing Proxy Management Tier
module "api_gateway_plane" {
  source                = "../../modules/apim"
  environment           = var.environment
  location              = var.location
  resource_group_name   = var.resource_group_name
  integration_subnet_id = data.terraform_remote_state.infra.outputs.subnet_ids["integration"]
  tenant_id             = var.tenant_id

  # Dynamically compiling templates at execution time
  global_policy_xml = templatefile("${path.module}/policies/global_policy.xml.tpl", {
    tenant_id = var.tenant_id
  })

  operation_policy_xml = templatefile("${path.module}/policies/operational.xml.tpl", {
    rate_limit_calls = var.environment == "prod" ? 500 : 50
    backend_url      = "http://nginx-internal.spoke.local/chat/stream"
  })
}