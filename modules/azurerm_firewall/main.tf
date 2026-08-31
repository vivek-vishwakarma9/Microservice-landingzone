resource "azurerm_public_ip" "public_ip" {
  for_each = var.azure_firewalls

  name                = "${each.value.name}-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = each.value.tags
}

resource "azurerm_public_ip" "mgmt_public_ip" {
  for_each = {
    for k, v in var.azure_firewalls : k => v
    if v.sku_tier == "Basic"
  }

  name                = "${each.value.name}-mgmt-pip"
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = each.value.tags
}

resource "azurerm_firewall_policy" "policy" {
  for_each = {
    for k, v in var.azure_firewalls : k => v
    if v.enable_policy != false
  }

  name                = "${each.value.name}-policy"
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  sku                 = each.value.sku_tier
  tags                = each.value.tags
}

resource "azurerm_firewall_policy_rule_collection_group" "rule_collection_group" {
  for_each = {
    for k, v in var.azure_firewalls : k => v
    if v.enable_policy != false && (length(v.network_rules) > 0 || length(v.application_rules) > 0)
  }

  name               = "${each.value.name}-rule-group"
  firewall_policy_id = azurerm_firewall_policy.policy[each.key].id
  priority           = 500

  dynamic "network_rule_collection" {
    for_each = length(each.value.network_rules) > 0 ? [1] : []
    content {
      name     = "network-rule-collection"
      priority = 200
      action   = "Allow"

      dynamic "rule" {
        for_each = each.value.network_rules
        content {
          name                  = rule.value.name
          protocols             = rule.value.protocols
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          destination_ports     = rule.value.destination_ports
        }
      }
    }
  }

  dynamic "application_rule_collection" {
    for_each = length(each.value.application_rules) > 0 ? [1] : []
    content {
      name     = "app-rule-collection"
      priority = 300
      action   = "Allow"

      dynamic "rule" {
        for_each = each.value.application_rules
        content {
          name              = rule.value.name
          source_addresses  = rule.value.source_addresses
          destination_fqdns = rule.value.target_fqdns

          dynamic "protocols" {
            for_each = rule.value.protocols
            content {
              type = protocols.value.type
              port = protocols.value.port
            }
          }
        }
      }
    }
  }
}

resource "azurerm_firewall" "firewall" {
  for_each = var.azure_firewalls

  name                = each.value.name
  location            = each.value.location
  resource_group_name = each.value.resource_group_name
  sku_name            = each.value.sku_name
  sku_tier            = each.value.sku_tier
  firewall_policy_id  = try(azurerm_firewall_policy.policy[each.key].id, null)
  tags                = each.value.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = each.value.subnet_id
    public_ip_address_id = azurerm_public_ip.public_ip[each.key].id
  }

  dynamic "management_ip_configuration" {
    for_each = each.value.sku_tier == "Basic" ? [1] : []
    content {
      name                 = "mgmtConfiguration"
      subnet_id            = each.value.management_subnet_id
      public_ip_address_id = azurerm_public_ip.mgmt_public_ip[each.key].id
    }
  }
}
