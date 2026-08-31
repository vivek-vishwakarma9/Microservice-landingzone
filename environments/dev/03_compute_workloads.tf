# ==============================================================================
# 03_COMPUTE_WORKLOADS.TF - AKS Clusters, ACR, VMs, Function Apps & Entra ID
# ==============================================================================

module "acrs" {
  source = "../../modules/azurerm_container_registry"
  acrs   = var.acrs

  depends_on = [module.resource_groups]
}

module "aks" {
  source = "../../modules/azurerm_kubernetes_cluster"

  clusters = {
    for k, v in var.aks_clusters : k => merge(v, {
      vnet_subnet_id = v.subnet_id != null ? v.subnet_id : (v.subnet_key != null ? module.vnets.subnets[v.subnet_key].id : null)
    })
  }

  depends_on = [module.resource_groups, module.vnets]
}

data "azurerm_key_vault_secret" "vm_existing_passwords" {
  for_each     = { for k, v in var.virtual_machines : k => v if v.key_vault_secret_name != null }
  name         = each.value.key_vault_secret_name
  key_vault_id = module.key_vaults.vaults[each.value.key_vault_key].id
}

module "virtual_machines" {
  source = "../../modules/azurerm_windows_virtual_machine"

  virtual_machines = {
    for k, v in var.virtual_machines : k => merge(v, {
      admin_password = v.key_vault_secret_name != null ? data.azurerm_key_vault_secret.vm_existing_passwords[k].value : (v.admin_password != null ? v.admin_password : random_password.vm_password.result)
      subnet_id      = v.subnet_id != null ? v.subnet_id : module.vnets.subnets[v.subnet_key].id
      identity_ids   = v.identity_key != null ? [module.user_identities.identities[v.identity_key].id] : null
    })
  }

  depends_on = [module.vnets, module.user_identities, module.key_vaults]
}

module "function_apps" {
  source = "../../modules/azurerm_linux_function_app"

  function_apps = {
    for k, v in var.function_apps : k => merge(v, {
      storage_account_name       = module.storage_accounts.storage_accounts[v.storage_account_key].name
      storage_account_access_key = module.storage_accounts.primary_access_keys[v.storage_account_key]
    })
  }

  depends_on = [module.resource_groups, module.storage_accounts]
}

module "entra_external_ids" {
  source             = "../../modules/azurerm_aadb2c_directory"
  entra_external_ids = var.entra_external_ids

  depends_on = [module.resource_groups]
}
