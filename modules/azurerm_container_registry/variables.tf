variable "acrs" {
  description = "A map of Azure Container Registries to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = optional(string, "Basic")
    admin_enabled       = optional(bool, false)
    tags                = optional(map(string), {})
  }))
  default = {}
}
