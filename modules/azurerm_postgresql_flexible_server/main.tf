resource "azurerm_postgresql_flexible_server" "postgresql_flexible_server" {
  for_each = var.postgresql_servers

  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  version                       = each.value.version
  administrator_login           = each.value.administrator_login
  administrator_password        = each.value.administrator_password
  sku_name                      = try(each.value.sku_name, "GP_Standard_D2s_v3")
  storage_mb                    = each.value.storage_mb
  zone                          = try(each.value.zone, null)
  public_network_access_enabled = try(each.value.public_network_access_enabled, false)
  tags                          = each.value.tags
}
