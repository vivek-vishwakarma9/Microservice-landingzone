variable "azure_firewalls" {
  description = "Map of Azure Firewalls to create with optional Policy and Rules"
  type = map(object({
    name                 = string
    resource_group_name  = string
    location             = string
    sku_name             = optional(string, "AZFW_VNet")
    sku_tier             = optional(string, "Basic")
    subnet_id            = string
    management_subnet_id = optional(string)
    enable_policy        = optional(bool, true)
    network_rules = optional(map(object({
      name                  = string
      priority              = number
      action                = string
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
      protocols             = list(string)
    })), {})
    application_rules = optional(map(object({
      name             = string
      priority         = number
      action           = string
      source_addresses = list(string)
      target_fqdns     = list(string)
      protocols = optional(list(object({
        type = string
        port = number
      })), [
        { type = "Https", port = 443 },
        { type = "Http", port = 80 }
      ])
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}
}
