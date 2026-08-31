resource "azurerm_public_ip" "public_ip" {
  for_each = var.nat_gateways

  name                = "${each.value.name}-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = each.value.tags
}

resource "azurerm_nat_gateway" "nat_gateway" {
  for_each = var.nat_gateways

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku_name            = each.value.sku_name
  tags                = each.value.tags
}

resource "azurerm_nat_gateway_public_ip_association" "nat_gateway_public_ip_association" {
  for_each = var.nat_gateways

  nat_gateway_id       = azurerm_nat_gateway.nat_gateway[each.key].id
  public_ip_address_id = azurerm_public_ip.public_ip[each.key].id
}
