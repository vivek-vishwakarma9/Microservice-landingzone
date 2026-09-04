variable "resource_groups" {
  description = "Map of resource groups"
  type = map(object({
    name     = string
    location = string
    tags     = optional(map(string), {})
  }))
  default = {}
}

variable "vnets" {
  description = "Map of Virtual Networks"
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

variable "nat_gateways" {
  description = "Map of NAT Gateways"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku_name            = optional(string, "Standard")
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "bastions" {
  description = "Map of Bastion Hosts"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = optional(string, "Basic")
    subnet_key          = optional(string, "vnet1-bastion_subnet")
    subnet_id           = optional(string)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "vpn_gateways" {
  description = "Map of VPN Gateways"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    type                = optional(string, "Vpn")
    vpn_type            = optional(string, "RouteBased")
    sku                 = optional(string, "VpnGw1")
    subnet_key          = optional(string, "vnet1-gateway_subnet")
    subnet_id           = optional(string)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "azure_firewalls" {
  description = "Map of Azure Firewalls"
  type = map(object({
    name                  = string
    resource_group_name   = string
    location              = string
    sku_name              = optional(string, "AZFW_VNet")
    sku_tier              = optional(string, "Basic")
    subnet_key            = optional(string, "vnet1-firewall_subnet")
    subnet_id             = optional(string)
    management_subnet_key = optional(string, "vnet1-firewall_mgmt_subnet")
    management_subnet_id  = optional(string)
    enable_policy         = optional(bool, true)
    network_rules = optional(map(object({
      name                  = string
      priority              = number
      action                = string
      source_addresses      = list(string)
      destination_addresses = list(string)
      destination_ports     = list(string)
      protocols             = list(string)
    })), {})
    application_rules = optional(map(object({
      name             = string
      priority         = number
      action           = string
      source_addresses = list(string)
      target_fqdns     = list(string)
      protocols = optional(list(object({
        type = string
        port = number
        })), [
        { type = "Https", port = 443 },
        { type = "Http", port = 80 }
      ])
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "nsgs" {
  description = "Map of Network Security Groups"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    subnet_key          = optional(string)
    subnet_id           = optional(string)
    security_rules = optional(map(object({
      name                         = string
      priority                     = number
      direction                    = string
      access                       = string
      protocol                     = string
      source_port_range            = optional(string, "*")
      destination_port_range       = optional(string)
      source_port_ranges           = optional(list(string))
      destination_port_ranges      = optional(list(string))
      source_address_prefix        = optional(string)
      source_address_prefixes      = optional(list(string))
      destination_address_prefix   = optional(string)
      destination_address_prefixes = optional(list(string))
    })), {})
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "acrs" {
  description = "Map of Azure Container Registries"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    sku                 = optional(string, "Basic")
    admin_enabled       = optional(bool, false)
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "aks_clusters" {
  description = "Map of AKS Clusters"
  type = map(object({
    name                    = string
    resource_group_name     = string
    location                = string
    dns_prefix              = string
    sku_tier                = optional(string, "Standard")
    node_count              = optional(number, 2)
    vm_size                 = optional(string, "Standard_D2_v3")
    subnet_key              = optional(string, "vnet1-aks_subnet")
    subnet_id               = optional(string)
    private_cluster_enabled = optional(bool, true)
    network_plugin          = optional(string, "azure")
    network_plugin_mode     = optional(string, "overlay")
    pod_cidr                = optional(string, "10.244.0.0/16")
    service_cidr            = optional(string, "10.0.8.0/24")
    dns_service_ip          = optional(string, "10.0.8.10")
    tags                    = optional(map(string), {})
  }))
  default = {}
}

variable "key_vaults" {
  description = "Map of Key Vaults"
  type = map(object({
    name                          = string
    resource_group_name           = string
    location                      = string
    tenant_id                     = optional(string)
    sku_name                      = optional(string, "standard")
    public_network_access_enabled = optional(bool, true)
    network_acls_default_action   = optional(string, "Allow")
    tags                          = optional(map(string), {})
  }))
  default = {}
}

variable "postgresql_servers" {
  description = "Map of PostgreSQL Flexible Servers"
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

variable "cosmosdb_accounts" {
  description = "Map of Cosmos DB Accounts"
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

variable "apim_services" {
  description = "Map of API Management Services"
  type = map(object({
    name                          = string
    resource_group_name           = string
    location                      = string
    publisher_name                = string
    publisher_email               = string
    sku_name                      = optional(string, "Basic_1")
    public_network_access_enabled = optional(bool, true)
    identity_type                 = optional(string, "SystemAssigned")
    identity_key                  = optional(string)
    identity_ids                  = optional(list(string))
    tags                          = optional(map(string), {})
  }))
  default = {}
}

variable "virtual_machines" {
  description = "Map of Windows Virtual Machines"
  type = map(object({
    name                  = string
    resource_group_name   = string
    location              = string
    size                  = optional(string, "Standard_D2_v3")
    admin_username        = optional(string, "azureuser")
    admin_password        = optional(string)
    key_vault_secret_name = optional(string)
    key_vault_key         = optional(string, "kv-dev")
    subnet_key            = optional(string, "vnet1-vm_subnet")
    subnet_id             = optional(string)
    identity_key          = optional(string)
    install_kubectl       = optional(bool, false)
    install_az_cli        = optional(bool, false)
    install_tools         = optional(bool, false)
    tags                  = optional(map(string), {})
  }))
  default = {}
}

variable "storage_accounts" {
  description = "Map of Storage Accounts"
  type = map(object({
    name                            = string
    resource_group_name             = string
    location                        = string
    account_tier                    = optional(string, "Standard")
    account_replication_type        = optional(string, "LRS")
    public_network_access_enabled   = optional(bool, false)
    allow_nested_items_to_be_public = optional(bool, false)
    tags                            = optional(map(string), {})
  }))
  default = {}
}

variable "function_apps" {
  description = "Map of Function Apps"
  type = map(object({
    name                       = string
    resource_group_name        = string
    location                   = string
    storage_account_key        = optional(string, "stfuncdev")
    storage_account_name       = optional(string)
    storage_account_access_key = optional(string)
    tags                       = optional(map(string), {})
  }))
  default = {}
}

variable "entra_external_ids" {
  description = "Map of Microsoft Entra External ID tenants"
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

variable "private_endpoints" {
  description = "Map of Private Endpoints configuration"
  type = map(object({
    name                  = string
    location              = string
    resource_group_name   = string
    subnet_key            = string
    target_type           = string
    target_name           = string
    subresource_names     = list(string)
    private_dns_zone_name = string
    vnet_key              = string
    tags                  = optional(map(string), {})
  }))
  default = {}
}

variable "user_identities" {
  description = "Map of User Assigned Managed Identities"
  type = map(object({
    name                = string
    resource_group_name = string
    location            = string
    tags                = optional(map(string), {})
  }))
  default = {}
}

variable "key_vault_secrets" {
  description = "Map of dynamic Key Vault Secrets driven 100% by tfvars"
  type = map(object({
    name          = string
    secret_type   = string
    raw_value     = optional(string)
    key_vault_key = optional(string, "kv-dev")
  }))
  default = {}
}

variable "role_assignments" {
  description = "Map of dynamic Role Assignments driven 100% by tfvars"
  type = map(object({
    role_definition_name = string
    principal_type       = string
    principal_key        = string
    scope_type           = string
    scope_key            = string
  }))
  default = {}
}
