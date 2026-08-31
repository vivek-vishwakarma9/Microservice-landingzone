variable "bastions" {
  description = "Map of Azure Bastion hosts to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = optional(string, "Basic")
    subnet_id           = string
    tags                = optional(map(string), {})
  }))
  default = {}
}
