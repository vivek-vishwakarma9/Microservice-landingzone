output "servers" {
  value     = azurerm_postgresql_flexible_server.postgresql_flexible_server
  sensitive = true
}
