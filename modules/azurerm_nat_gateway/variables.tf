variable "nat_gateways" {
  description = "Map of NAT Gateways to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku_name            = optional(string, "Standard")
    tags                = optional(map(string), {})
  }))
  default = {}
}
