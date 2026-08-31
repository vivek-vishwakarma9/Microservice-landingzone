variable "secrets" {
  description = "Map of Key Vault secrets to create."
  type = map(object({
    name         = string
    value        = string
    key_vault_id = string
    tags         = optional(map(string), {})
  }))
  default = {}
}
