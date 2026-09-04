resource "azurerm_key_vault" "key_vault" {
  for_each = var.key_vaults

  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  enabled_for_disk_encryption   = true
  tenant_id                     = each.value.tenant_id
  soft_delete_retention_days    = 90
  purge_protection_enabled      = coalesce(each.value.purge_protection_enabled, true)
  public_network_access_enabled = coalesce(each.value.public_network_access_enabled, true)
  sku_name                      = each.value.sku_name
  tags                          = each.value.tags

  dynamic "access_policy" {
    for_each = each.value.object_id != null ? [1] : []
    content {
      tenant_id = each.value.tenant_id
      object_id = each.value.object_id
      secret_permissions = [
        "Get", "List", "Set", "Delete", "Purge", "Recover"
      ]
    }
  }

  network_acls {
    bypass         = "AzureServices"
    default_action = "Allow"
  }

  lifecycle {
    ignore_changes = [purge_protection_enabled]
  }
}
