variable "entra_external_ids" {
  description = "Map of Microsoft Entra External ID (Azure AD B2C) tenants to create."
  type = map(object({
    country_code            = optional(string, "US")
    data_residency_location = optional(string, "United States")
    display_name            = string
    domain_name             = string
    resource_group_name     = string
    sku_name                = optional(string, "PremiumP1")
    tags                    = optional(map(string), {})
  }))
  default = {}
}
