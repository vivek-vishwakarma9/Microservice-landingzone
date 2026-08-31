resource "azurerm_virtual_network" "virtual_network" {
  for_each = var.vnets

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  address_space       = each.value.address_space
  tags                = each.value.tags
}

locals {
  subnets = flatten([
    for vnet_key, vnet in var.vnets : [
      for subnet_key, subnet in vnet.subnets : {
        key              = "${vnet_key}-${subnet_key}"
        vnet_key         = vnet_key
        name             = subnet.name
        address_prefixes = subnet.address_prefixes
      }
    ]
  ])
}

resource "azurerm_subnet" "subnet" {
  for_each = { for s in local.subnets : s.key => s }

  name                 = each.value.name
  resource_group_name  = var.vnets[each.value.vnet_key].resource_group_name
  virtual_network_name = azurerm_virtual_network.virtual_network[each.value.vnet_key].name
  address_prefixes     = each.value.address_prefixes
}
