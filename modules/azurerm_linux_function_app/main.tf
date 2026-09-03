resource "azurerm_service_plan" "service_plan" {
  for_each = var.function_apps

  name                = "${each.value.name}-plan"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  os_type             = try(each.value.os_type, "Linux")
  sku_name            = try(each.value.sku_name, "Y1")
  tags                = each.value.tags
}

resource "azurerm_linux_function_app" "linux_function_app" {
  for_each = var.function_apps

  name                          = each.value.name
  resource_group_name           = each.value.resource_group_name
  location                      = each.value.location
  storage_account_name          = each.value.storage_account_name
  storage_account_access_key    = each.value.storage_account_access_key
  service_plan_id               = azurerm_service_plan.service_plan[each.key].id
  public_network_access_enabled = try(each.value.public_network_access_enabled, true)
  https_only                    = try(each.value.https_only, true)
  tags                          = each.value.tags

  identity {
    type = try(each.value.identity_type, "SystemAssigned")
  }

  site_config {}
}
