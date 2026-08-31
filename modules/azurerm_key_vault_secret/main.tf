resource "azurerm_key_vault_secret" "key_vault_secret" {
  for_each = var.secrets

  name         = each.value.name
  value        = each.value.value
  key_vault_id = each.value.key_vault_id
  content_type = "text/plain"
  tags         = each.value.tags
}
