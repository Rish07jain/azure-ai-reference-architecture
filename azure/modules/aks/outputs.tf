output "aks_cluster_id" {
  value       = azurerm_kubernetes_cluster.aks.id
  description = "The Resource ID of the provisioned Azure Kubernetes Cluster"
}

output "aks_identity_client_id" {
  value       = azurerm_user_assigned_identity.aks_identity.client_id
  description = "The Client ID of the cluster's managed identity used for RBAC role assignments"
}