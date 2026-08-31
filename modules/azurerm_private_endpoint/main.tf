resource "azurerm_private_dns_zone" "private_dns_zone" {
  for_each = var.private_endpoints

  name                = each.value.private_dns_zone_name
  resource_group_name = each.value.resource_group_name
  tags                = each.value.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_vnet_link" {
  for_each = var.private_endpoints

  name                  = "${each.value.name}-dns-vnet-link"
  resource_group_name   = each.value.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone[each.key].name
  virtual_network_id    = each.value.vnet_id
  tags                  = each.value.tags
}

resource "azurerm_private_endpoint" "private_endpoint" {
  for_each = var.private_endpoints

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  subnet_id           = each.value.subnet_id
  tags                = each.value.tags

  private_service_connection {
    name                           = "${each.value.name}-psc"
    private_connection_resource_id = each.value.target_resource_id
    subresource_names              = each.value.subresource_names
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "${each.value.name}-dns-group"
    private_dns_zone_ids = [azurerm_private_dns_zone.private_dns_zone[each.key].id]
  }
}
