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
  source          = "../../modules/azurerm_resource_group"
  resource_groups = var.resource_groups
}

# User Assigned Managed Identities
module "user_identities" {
  source          = "../../modules/azurerm_user_assigned_identity"
  user_identities = var.user_identities

  depends_on = [module.resource_groups]
}
