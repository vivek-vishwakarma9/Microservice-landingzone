variable "virtual_machines" {
  description = "Map of Virtual Machines to create."
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    size                = optional(string, "Standard_D2_v3")
    admin_username      = optional(string, "azureuser")
    admin_password      = optional(string)
    subnet_id           = string
    install_kubectl     = optional(bool, false)
    install_az_cli      = optional(bool, false)
    install_tools       = optional(bool, false)
    identity_ids        = optional(list(string))
    tags                = optional(map(string), {})
  }))
  default = {}
}
