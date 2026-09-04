resource "azurerm_public_ip" "public_ip" {
  for_each = var.vpn_gateways

  name                = "${each.value.name}-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = each.value.tags

  lifecycle {
    ignore_changes = [zones, sku, allocation_method]
  }
}

resource "azurerm_virtual_network_gateway" "virtual_network_gateway" {
  for_each = var.vpn_gateways

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  type                = each.value.type
  vpn_type            = each.value.vpn_type
  sku                 = each.value.sku
  tags                = each.value.tags

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.public_ip[each.key].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = each.value.subnet_id
  }

  lifecycle {
    ignore_changes = [sku, vpn_type, type]
  }
}
