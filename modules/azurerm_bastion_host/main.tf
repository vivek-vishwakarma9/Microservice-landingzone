resource "azurerm_public_ip" "public_ip" {
  for_each = var.bastions

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

resource "azurerm_bastion_host" "bastion_host" {
  for_each = var.bastions

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku                 = each.value.sku
  tags                = each.value.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = each.value.subnet_id
    public_ip_address_id = azurerm_public_ip.public_ip[each.key].id
  }
}
