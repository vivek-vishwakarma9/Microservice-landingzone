resource "azurerm_public_ip" "public_ip" {
  for_each = var.vpn_gateways

  name                = "${each.value.name}-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = coalesce(each.value.allocation_method, "Static")
  sku                 = coalesce(each.value.public_ip_sku, "Standard")
  zones               = each.value.zones
  tags                = each.value.tags
}

resource "azurerm_virtual_network_gateway" "virtual_network_gateway" {
  for_each = var.vpn_gateways

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  type                = coalesce(each.value.type, "Vpn")
  vpn_type            = coalesce(each.value.vpn_type, "RouteBased")
  sku                 = coalesce(each.value.sku, "VpnGw1")
  tags                = each.value.tags

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = each.value.subnet_id
  }
}
