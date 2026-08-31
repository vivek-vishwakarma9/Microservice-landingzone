resource "azurerm_aadb2c_directory" "aadb2c_directory" {
  for_each = var.entra_external_ids

  country_code            = each.value.country_code
  data_residency_location = each.value.data_residency_location
  display_name            = each.value.display_name
  domain_name             = each.value.domain_name
  resource_group_name     = each.value.resource_group_name
  sku_name                = each.value.sku_name
  tags                    = each.value.tags
}
