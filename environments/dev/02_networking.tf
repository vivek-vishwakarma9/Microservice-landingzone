# ==============================================================================
# 02_NETWORKING.TF - VNets, Subnets, NAT Gateways, Bastions & Azure Firewalls
# ==============================================================================

module "vnets" {
  source = "../../modules/azurerm_virtual_network"
  vnets  = var.vnets

  depends_on = [module.resource_groups]
}

module "nat_gateways" {
  source       = "../../modules/azurerm_nat_gateway"
  nat_gateways = var.nat_gateways

  depends_on = [module.vnets]
}

module "bastions" {
  source = "../../modules/azurerm_bastion_host"

  bastions = {
    for k, v in var.bastions : k => merge(v, {
      subnet_id = v.subnet_id != null ? v.subnet_id : module.vnets.subnets[v.subnet_key].id
    })
  }

  depends_on = [module.vnets]
}

module "vpn_gateways" {
  source = "../../modules/azurerm_virtual_network_gateway"

  vpn_gateways = {
    for k, v in var.vpn_gateways : k => merge(v, {
      subnet_id = v.subnet_id != null ? v.subnet_id : module.vnets.subnets[v.subnet_key].id
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
    })
  }

  depends_on = [module.vnets]
}

module "nsgs" {
  source = "../../modules/azurerm_network_security_group"

  nsgs = {
    for k, v in var.nsgs : k => merge(v, {
      subnet_id = v.subnet_id != null ? v.subnet_id : (v.subnet_key != null ? module.vnets.subnets[v.subnet_key].id : null)
    })
  }

  depends_on = [module.vnets]
}
