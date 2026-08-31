resource "azurerm_key_vault" "key_vault" {
  for_each = var.key_vaults

  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  enabled_for_disk_encryption   = true
  tenant_id                     = each.value.tenant_id
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  public_network_access_enabled = false
  sku_name                      = each.value.sku_name
  tags                          = each.value.tags

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
}
