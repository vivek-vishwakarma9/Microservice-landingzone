variable "vpn_gateways" {
  description = "Map of Virtual Network VPN Gateways to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    type                = optional(string, "Vpn")
    vpn_type            = optional(string, "RouteBased")
    sku                 = optional(string, "VpnGw1")
    subnet_id           = string
    tags                = optional(map(string), {})
  }))
  default = {}
}
