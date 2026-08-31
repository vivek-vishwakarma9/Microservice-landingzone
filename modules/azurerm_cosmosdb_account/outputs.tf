output "accounts" {
  value     = azurerm_cosmosdb_account.cosmosdb_account
  sensitive = true
}
