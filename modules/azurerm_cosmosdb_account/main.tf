resource "azurerm_cosmosdb_account" "cosmosdb_account" {
  for_each = var.cosmosdb_accounts

  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  offer_type                    = coalesce(each.value.offer_type, "Standard")
  kind                          = coalesce(each.value.kind, "GlobalDocumentDB")
  public_network_access_enabled = coalesce(each.value.public_network_access_enabled, false)
  tags                          = each.value.tags

  consistency_policy {
    consistency_level = coalesce(each.value.consistency_level, "Session")
  }

  geo_location {
    location          = each.value.location
    failover_priority = 0
  }
}
