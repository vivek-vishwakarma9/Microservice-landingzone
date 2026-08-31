variable "function_apps" {
  description = "Map of Function Apps to create."
  type = map(object({
    name                       = string
    resource_group_name        = string
    location                   = string
    storage_account_name       = string
    storage_account_access_key = string
    tags                       = optional(map(string), {})
  }))
  default = {}
}
