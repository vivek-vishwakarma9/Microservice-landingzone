output "accounts" {
  value = {
    for k, v in azurerm_cosmosdb_account.cosmosdb_account : k => {
      id          = v.id
      name        = v.name
      endpoint    = v.endpoint
      primary_key = v.primary_key
    }
  }
  sensitive = true
}
