resource "azurerm_api_management" "api_management" {
  for_each = var.apim_services

  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  publisher_name                = each.value.publisher_name
  publisher_email               = each.value.publisher_email
  sku_name                      = each.value.sku_name
  public_network_access_enabled = false
  tags                          = each.value.tags

  dynamic "identity" {
    for_each = each.value.identity_type != null ? [1] : []
    content {
      type         = each.value.identity_type
      identity_ids = contains(["UserAssigned", "SystemAssigned, UserAssigned"], coalesce(each.value.identity_type, "")) ? each.value.identity_ids : null
    }
  }
}
