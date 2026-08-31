variable "private_endpoints" {
  description = "Map of Private Endpoints to create with integrated Private DNS Zones."
  type = map(object({
    name                  = string
    location              = string
    resource_group_name   = string
    subnet_id             = string
    target_resource_id    = string
    subresource_names     = list(string)
    private_dns_zone_name = string
    vnet_id               = string
    tags                  = optional(map(string), {})
  }))
  default = {}
}
