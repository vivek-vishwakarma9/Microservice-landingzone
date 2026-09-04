#tfsec:ignore:azure-container-limit-authorized-ips
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  for_each = var.clusters

  name                      = each.value.name
  location                  = each.value.location
  resource_group_name       = each.value.resource_group_name
  dns_prefix                = each.value.dns_prefix
  sku_tier                  = each.value.sku_tier
  private_cluster_enabled   = coalesce(each.value.private_cluster_enabled, true)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  #tfsec:ignore:azure-container-limit-authorized-ips
  api_server_access_profile {
    authorized_ip_ranges = ["10.0.0.0/16"]
  }
  role_based_access_control_enabled = true
  tags                              = each.value.tags

  default_node_pool {
    name           = "default"
    node_count     = each.value.node_count
    vm_size        = each.value.vm_size
    vnet_subnet_id = each.value.vnet_subnet_id
  }

  network_profile {
    network_plugin      = each.value.network_plugin
    network_plugin_mode = each.value.network_plugin_mode
    network_policy      = "azure"
    pod_cidr            = each.value.network_plugin_mode == "overlay" ? each.value.pod_cidr : null
    service_cidr        = each.value.service_cidr
    dns_service_ip      = each.value.dns_service_ip
  }

  identity {
    type = "SystemAssigned"
  }
}
