variable "key_vaults" {
  description = "Map of Key Vaults to create."
  type = map(object({
    name                          = string
    resource_group_name           = string
    location                      = string
    tenant_id                     = string
    object_id                     = optional(string)
    sku_name                      = optional(string, "standard")
    public_network_access_enabled = optional(bool, true)
    network_acls_default_action   = optional(string, "Allow")
    tags                          = optional(map(string), {})
  }))
  default = {}
}
