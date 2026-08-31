variable "storage_accounts" {
  description = "Map of Storage Accounts to create."
  type = map(object({
    name                            = string
    resource_group_name             = string
    location                        = string
    account_tier                    = optional(string, "Standard")
    account_replication_type        = optional(string, "LRS")
    public_network_access_enabled   = optional(bool, false)
    allow_nested_items_to_be_public = optional(bool, false)
    tags                            = optional(map(string), {})
  }))
  default = {}
}
