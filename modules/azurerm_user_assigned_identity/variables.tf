variable "user_identities" {
  description = "Map of User Assigned Managed Identities to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    tags                = optional(map(string), {})
  }))
  default = {}
}
