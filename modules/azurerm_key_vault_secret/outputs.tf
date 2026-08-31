output "secrets" {
  value     = azurerm_key_vault_secret.key_vault_secret
  sensitive = true
}
