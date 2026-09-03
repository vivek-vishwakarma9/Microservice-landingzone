resource "azurerm_storage_account" "storage_account" {
  for_each = var.storage_accounts

  name                            = each.value.name
  resource_group_name             = each.value.resource_group_name
  location                        = each.value.location
  account_tier                    = each.value.account_tier
  account_replication_type        = each.value.account_replication_type
  public_network_access_enabled   = try(each.value.public_network_access_enabled, false)
  allow_nested_items_to_be_public = try(each.value.allow_nested_items_to_be_public, false)
  min_tls_version                 = try(each.value.min_tls_version, "TLS1_2")
  tags                            = each.value.tags
}
