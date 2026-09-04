# ==============================================================================
# 04_DATABASES_STORAGE.TF - Key Vault, PostgreSQL, CosmosDB, APIM & Storage
# ==============================================================================

module "key_vaults" {
  source = "../../modules/azurerm_key_vault"

  key_vaults = {
    for k, v in var.key_vaults : k => merge(v, {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = data.azurerm_client_config.current.object_id
    })
  }

  depends_on = [module.resource_groups]
}

module "postgresql" {
  source = "../../modules/azurerm_postgresql_flexible_server"

  postgresql_servers = {
    for k, v in var.postgresql_servers : k => merge(v, {
      administrator_password = v.administrator_password != null ? v.administrator_password : random_password.psql_password.result
    })
  }

  depends_on = [module.resource_groups]
}

module "cosmosdb" {
  source            = "../../modules/azurerm_cosmosdb_account"
  cosmosdb_accounts = var.cosmosdb_accounts

  depends_on = [module.resource_groups]
}

module "apim" {
  source = "../../modules/azurerm_api_management"

  apim_services = {
    for k, v in var.apim_services : k => merge(v, {
      identity_ids = v.identity_ids != null ? v.identity_ids : (v.identity_key != null ? [module.user_identities.identities[v.identity_key].id] : null)
    })
  }

  depends_on = [module.resource_groups, module.user_identities]
}

module "storage_accounts" {
  source           = "../../modules/azurerm_storage_account"
  storage_accounts = var.storage_accounts

  depends_on = [module.resource_groups]
}

# Key Vault Secrets (Stores DB & VM passwords driven by tfvars)
locals {
  secret_value_map = {
    "random_psql"        = random_password.psql_password.result
    "random_vm"          = random_password.vm_password.result
    "cosmos_primary_key" = try(module.cosmosdb.accounts["cosmos-dev"].primary_key, "")
  }
}

module "key_vault_secrets" {
  source = "../../modules/azurerm_key_vault_secret"

  secrets = {
    for k, v in var.key_vault_secrets : k => {
      name         = v.name
      value        = v.secret_type == "raw" ? v.raw_value : local.secret_value_map[v.secret_type]
      key_vault_id = module.key_vaults.vaults[v.key_vault_key].id
    }
  }

  depends_on = [module.key_vaults, module.cosmosdb]
}
