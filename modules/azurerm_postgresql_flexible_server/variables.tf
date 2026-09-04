variable "postgresql_servers" {
  description = "Map of PostgreSQL Flexible Servers to create."
  type = map(object({
    name                   = string
    resource_group_name    = string
    location               = string
    version                = optional(string, "15")
    sku_name               = optional(string, "B_Standard_B1ms")
    storage_mb             = optional(number, 32768)
    administrator_login    = optional(string, "psqladmin")
    administrator_password = optional(string)
    tags                   = optional(map(string), {})
  }))
  default = {}
}
