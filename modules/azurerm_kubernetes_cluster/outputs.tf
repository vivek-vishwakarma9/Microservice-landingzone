output "clusters" {
  value     = azurerm_kubernetes_cluster.kubernetes_cluster
  sensitive = true
}
