variable "cosmosdb_accounts" {
  description = "Map of Cosmos DB accounts to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    offer_type          = optional(string, "Standard")
    kind                = optional(string, "GlobalDocumentDB")
    tags                = optional(map(string), {})
  }))
  default = {}
}
