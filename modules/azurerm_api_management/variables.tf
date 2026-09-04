variable "apim_services" {
  description = "Map of API Management Services to create."
  type = map(object({
    name                          = string
    resource_group_name           = string
    location                      = string
    publisher_name                = string
    publisher_email               = string
    sku_name                      = optional(string, "Basic_1")
    public_network_access_enabled = optional(bool, true)
    identity_type                 = optional(string, "SystemAssigned")
    identity_ids                  = optional(list(string))
    tags                          = optional(map(string), {})
  }))
  default = {}
}
