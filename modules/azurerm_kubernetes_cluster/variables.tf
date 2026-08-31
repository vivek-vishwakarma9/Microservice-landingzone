variable "clusters" {
  description = "A map of AKS clusters to create."
  type = map(object({
    name                    = string
    resource_group_name     = string
    location                = string
    dns_prefix              = string
    sku_tier                = optional(string, "Standard")
    node_count              = optional(number, 2)
    vm_size                 = optional(string, "Standard_D2_v3")
    vnet_subnet_id          = optional(string)
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
