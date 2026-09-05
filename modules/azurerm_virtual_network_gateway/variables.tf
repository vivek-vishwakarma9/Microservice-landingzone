variable "vpn_gateways" {
  description = "Map of Virtual Network VPN Gateways to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    type                = optional(string, "Vpn")
    vpn_type            = optional(string, "RouteBased")
    sku                 = optional(string, "VpnGw1")
    allocation_method   = optional(string, "Static")
    public_ip_sku       = optional(string, "Standard")
    zones               = optional(list(string))
    subnet_id           = string
    vpn_client_configuration = optional(object({
      address_space        = list(string)
      vpn_client_protocols = optional(list(string))
      vpn_auth_types       = optional(list(string))
      tenant_id            = optional(string)
      aad_tenant           = optional(string)
      aad_audience         = optional(string)
      aad_issuer           = optional(string)
    }))
    tags                = optional(map(string), {})
  }))
  default = {}
}
