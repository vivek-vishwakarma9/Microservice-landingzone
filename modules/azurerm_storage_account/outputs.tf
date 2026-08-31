output "storage_accounts" {
  value     = azurerm_storage_account.storage_account
  sensitive = true
}

output "primary_access_keys" {
  value     = { for k, v in azurerm_storage_account.storage_account : k => v.primary_access_key }
  sensitive = true
}

output "ids" {
  value = { for k, v in azurerm_storage_account.storage_account : k => v.id }
}
