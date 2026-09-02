# ==============================================================================
# 05_DIRECTORIES_PE_RBAC.TF - Lookup Directories, Private Endpoints & RBAC Roles
# ==============================================================================

locals {
  # Master Directory of PaaS Resource IDs for Private Endpoints
  pe_target_resource_ids = merge(
    { for k, v in module.key_vaults.vaults : "key_vault-${k}" => v.id },
    { for k, v in module.postgresql.servers : "postgresql-${k}" => v.id },
    { for k, v in module.cosmosdb.accounts : "cosmosdb-${k}" => v.id },
    { for k, v in module.storage_accounts.ids : "storage_blob-${k}" => v },
    { for k, v in module.acrs.registries : "acr-${k}" => v.id },
    { for k, v in module.aks.clusters : "aks-${k}" => v.id }
  )

  # Master Directory of Managed Identities (Who gets the role?)
  identity_principal_ids = merge(
    { for k, v in module.aks.clusters : "aks-${k}" => v.kubelet_identity[0].object_id },
    { for k, v in module.function_apps.function_apps : "function_app-${k}" => v.identity[0].principal_id },
    { for k, v in module.apim.apim_services : "apim-${k}" => v.identity[0].principal_id },
    { for k, v in module.user_identities.identities : "user_identity-${k}" => v.principal_id }
  )

  # Master Directory of Target Scopes (Where is the role assigned?)
  resource_scope_ids = merge(
    { for k, v in module.acrs.registries : "acr-${k}" => v.id },
    { for k, v in module.key_vaults.vaults : "key_vault-${k}" => v.id },
    { for k, v in module.storage_accounts.ids : "storage_account-${k}" => v },
    { for k, v in module.resource_groups.resource_groups : "resource_group-${k}" => v.id }
  )
}

# Zero-Trust Private Endpoints
module "private_endpoints" {
  source = "../../modules/azurerm_private_endpoint"

  private_endpoints = {
    for k, v in var.private_endpoints : k => merge(v, {
      subnet_id          = module.vnets.subnets[v.subnet_key].id
      vnet_id            = module.vnets.vnets[v.vnet_key].id
      target_resource_id = local.pe_target_resource_ids["${v.target_type}-${v.target_name}"]
      tags               = merge(local.mandatory_tags, coalesce(v.tags, {}))
    })
  }

  depends_on = [
    module.vnets,
    module.key_vaults,
    module.postgresql,
    module.cosmosdb,
    module.storage_accounts,
    module.acrs,
    module.aks
  ]
}

# Zero-Trust RBAC Role Assignments
module "role_assignments" {
  source = "../../modules/azurerm_role_assignment"

  assignments = {
    for k, v in var.role_assignments : k => {
      role_definition_name = v.role_definition_name
      principal_id         = local.identity_principal_ids["${v.principal_type}-${v.principal_key}"]
      scope                = local.resource_scope_ids["${v.scope_type}-${v.scope_key}"]
    }
  }

  depends_on = [
    module.aks,
    module.acrs,
    module.function_apps,
    module.apim,
    module.key_vaults,
    module.storage_accounts,
    module.user_identities
  ]
}
