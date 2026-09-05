# ==============================================================================
# 02_NETWORKING.TF - VNets, Subnets, NAT Gateways, Bastions & Azure Firewalls
# ==============================================================================

module "vnets" {
  source = "../../modules/azurerm_virtual_network"
  vnets = {
    for k, v in var.vnets : k => merge(v, {
      tags = merge(local.default_tags, v.tags != null ? v.tags : {})
    })
  }

  depends_on = [module.resource_groups]
}

module "nat_gateways" {
  source = "../../modules/azurerm_nat_gateway"
  nat_gateways = {
    for k, v in var.nat_gateways : k => merge(v, {
      tags = merge(local.default_tags, v.tags != null ? v.tags : {})
    })
  }

  depends_on = [module.vnets]
}

module "bastions" {
  source = "../../modules/azurerm_bastion_host"

  bastions = {
    for k, v in var.bastions : k => merge(v, {
      subnet_id = v.subnet_id != null ? v.subnet_id : module.vnets.subnets[v.subnet_key].id
      tags      = merge(local.default_tags, v.tags != null ? v.tags : {})
    })
  }

  depends_on = [module.vnets]
}

module "vpn_gateways" {
  source = "../../modules/azurerm_virtual_network_gateway"

  vpn_gateways = {
    for k, v in var.vpn_gateways : k => merge(v, {
      subnet_id = v.subnet_id != null ? v.subnet_id : module.vnets.subnets[v.subnet_key].id
      tags      = merge(local.default_tags, v.tags != null ? v.tags : {})
      vpn_client_configuration = v.vpn_client_configuration != null ? merge(v.vpn_client_configuration, {
        tenant_id    = try(v.vpn_client_configuration.tenant_id, data.azurerm_client_config.current.tenant_id)
        aad_tenant   = try(v.vpn_client_configuration.aad_tenant, "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/")
        aad_issuer   = try(v.vpn_client_configuration.aad_issuer, "https://sts.windows.net/${data.azurerm_client_config.current.tenant_id}/")
        aad_audience = try(v.vpn_client_configuration.aad_audience, "41b23e61-6c1e-4545-b367-cd054e0ed4b4")
      }) : null
    })
  }

  depends_on = [module.vnets]
}

module "azure_firewalls" {
  source = "../../modules/azurerm_firewall"

  azure_firewalls = {
    for k, v in var.azure_firewalls : k => merge(v, {
      subnet_id            = v.subnet_id != null ? v.subnet_id : module.vnets.subnets[v.subnet_key].id
      management_subnet_id = v.management_subnet_key != null ? module.vnets.subnets[v.management_subnet_key].id : null
      tags                 = merge(local.default_tags, v.tags != null ? v.tags : {})
    })
  }

  depends_on = [module.vnets]
}

module "nsgs" {
  source = "../../modules/azurerm_network_security_group"

  nsgs = {
    for k, v in var.nsgs : k => merge(v, {
      subnet_id = v.subnet_id != null ? v.subnet_id : (v.subnet_key != null ? module.vnets.subnets[v.subnet_key].id : null)
      tags      = merge(local.default_tags, v.tags != null ? v.tags : {})
    })
  }

  depends_on = [module.vnets]
}