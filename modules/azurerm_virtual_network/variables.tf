variable "vnets" {
  description = "Map of Virtual Networks to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    address_space       = list(string)
    subnets = optional(map(object({
      name             = string
      address_prefixes = list(string)
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}
}
