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

  dynamic "vpn_client_configuration" {
    for_each = try(each.value.vpn_client_configuration, null) != null ? [each.value.vpn_client_configuration] : []
    content {
      address_space        = vpn_client_configuration.value.address_space
      vpn_client_protocols = vpn_client_configuration.value.vpn_client_protocols
      vpn_auth_types       = vpn_client_configuration.value.vpn_auth_types
      aad_tenant           = vpn_client_configuration.value.aad_tenant
      aad_audience         = vpn_client_configuration.value.aad_audience
      aad_issuer           = vpn_client_configuration.value.aad_issuer
      dns_servers          = try(vpn_client_configuration.value.dns_servers, null)
    }
  }

  lifecycle {
    ignore_changes = [sku, vpn_type, type]
  }
}