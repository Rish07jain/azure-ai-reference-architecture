# Generates a User-Assigned Managed Identity for the AKS Control Plane
resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "id-aks-${var.environment}"
  location            = var.location
  resource_group_name = var.resource_group_name
}

# The actual Private AKS Cluster definition
resource "azurerm_kubernetes_cluster" "aks" {
  name                    = "aks-platformgpt-${var.environment}"
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = "azmaks-${var.environment}"
  
  # Crucial flag for the case study constraint: Enforces a strictly private cluster
  private_cluster_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = 3
    vm_size        = "Standard_D4ds_v5"
    vnet_subnet_id = var.compute_subnet_id # Attached directly to the isolated spoke compute subnet
  }

  # Leverages the explicit control plane Managed Identity rather than service principals
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

  network_profile {
    network_plugin    = "azure" # Azure CNI for native VNet pod IP allocation
    load_balancer_sku = "standard"
    outbound_type     = "userDefinedRouting" # All egress forced through the Hub Firewall
  }
}