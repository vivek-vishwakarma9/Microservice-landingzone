resource "azurerm_container_registry" "container_registry" {
  for_each = var.acrs

  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  sku                           = each.value.sku
  admin_enabled                 = each.value.admin_enabled
  public_network_access_enabled = try(each.value.public_network_access_enabled, true)
  tags                          = each.value.tags
}
