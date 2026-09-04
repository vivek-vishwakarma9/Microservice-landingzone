# ==============================================================================
# 01_CORE_IDENTITY.TF - Core Azure Subscription, Resource Groups & Identities
# ==============================================================================

data "azurerm_client_config" "current" {}

# Random Secure Passwords (Generated dynamically, stored in Key Vault)
resource "random_password" "psql_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "random_password" "vm_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

# Core Resource Groups
module "resource_groups" {
  source = "../../modules/azurerm_resource_group"
  resource_groups = {
    for k, v in var.resource_groups : k => merge(v, {
      tags = merge(local.default_tags, v.tags != null ? v.tags : {})
    })
  }
}

# User Assigned Managed Identities
module "user_identities" {
  source = "../../modules/azurerm_user_assigned_identity"
  user_identities = {
    for k, v in var.user_identities : k => merge(v, {
      tags = merge(local.default_tags, v.tags != null ? v.tags : {})
    })
  }

  depends_on = [module.resource_groups]
}

