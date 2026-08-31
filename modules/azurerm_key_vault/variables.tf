variable "key_vaults" {
  description = "Map of Key Vaults to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    tenant_id           = string
    sku_name            = optional(string, "standard")
    tags                = optional(map(string), {})
  }))
  default = {}
}
