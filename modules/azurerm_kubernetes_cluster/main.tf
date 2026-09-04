#tfsec:ignore:azure-container-limit-authorized-ips
resource "azurerm_kubernetes_cluster" "kubernetes_cluster" {
  for_each = var.clusters

  name                      = each.value.name
  location                  = each.value.location
  resource_group_name       = each.value.resource_group_name
  dns_prefix                = each.value.dns_prefix
  sku_tier                  = each.value.sku_tier
  private_cluster_enabled   = try(each.value.private_cluster_enabled, true)
  oidc_issuer_enabled       = true
  workload_identity_enabled = true

  dynamic "api_server_access_profile" {
    for_each = try(each.value.private_cluster_enabled, true) ? [] : [1]
    content {
      authorized_ip_ranges = try(each.value.authorized_ip_ranges, ["10.0.0.0/16"])
    }
  }
  role_based_access_control_enabled = true
  tags                              = each.value.tags

  default_node_pool {
    name                        = "default"
    node_count                  = each.value.node_count
    vm_size                     = each.value.vm_size
    vnet_subnet_id              = each.value.vnet_subnet_id
    temporary_name_for_rotation = "temppool"
  }

  network_profile {
    network_plugin      = try(each.value.network_plugin, "azure")
    network_plugin_mode = try(each.value.network_plugin_mode, "overlay")
    network_policy      = "azure"
    pod_cidr            = try(each.value.network_plugin_mode, "overlay") == "overlay" ? try(each.value.pod_cidr, null) : null
    service_cidr        = try(each.value.service_cidr, "172.16.0.0/16")
    dns_service_ip      = try(each.value.dns_service_ip, "172.16.0.10")
  }

  identity {
    type = "SystemAssigned"
  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].upgrade_settings,
      default_node_pool[0].vm_size
    ]
  }
}
