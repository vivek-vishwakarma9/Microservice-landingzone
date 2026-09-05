resource_groups = {
  "rg-dev" = {
    name     = "rg-eng-dev"
    location            = "East US"
    tags = {
      environment = "dev"
      managed_by  = "terraform"
      project     = "aionos-microservices"
    }
  }
  "rg-tfstate" = {
    name     = "rg-eng-dev-tfstate"
    location            = "East US"
    tags = {
      environment = "global"
      managed_by  = "terraform"
      purpose     = "terraform-state"
    }
  }
}

user_identities = {
  "uai-vm-dev" = {
    name                = "uai-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    tags = {
      environment = "dev"
    }
  }
}

vnets = {
  "vnet1" = {
    name                = "vnet-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    address_space       = ["10.0.0.0/16"]
    subnets = {
      "aks_subnet" = {
        name             = "snet-aks"
        address_prefixes = ["10.0.1.0/24"]
      }
      "vm_subnet" = {
        name             = "snet-workloads"
        address_prefixes = ["10.0.2.0/24"]
      }
      "bastion_subnet" = {
        name             = "AzureBastionSubnet"
        address_prefixes = ["10.0.3.0/27"]
      }
      "gateway_subnet" = {
        name             = "GatewaySubnet"
        address_prefixes = ["10.0.4.0/27"]
      }
      "firewall_subnet" = {
        name             = "AzureFirewallSubnet"
        address_prefixes = ["10.0.5.0/26"]
      }
      "firewall_mgmt_subnet" = {
        name             = "AzureFirewallManagementSubnet"
        address_prefixes = ["10.0.6.0/26"]
      }
      "pe_subnet" = {
        name             = "snet-private-endpoints"
        address_prefixes = ["10.0.7.0/24"]
      }
    }
    tags = {
      environment = "dev"
    }
  }
  "vnet2" = {
    name                = "vnet-eng-dev-002"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    address_space       = ["10.1.0.0/16"]
    subnets = {
      "peered_subnet" = {
        name             = "snet-secondary"
        address_prefixes = ["10.1.1.0/24"]
      }
    }
    tags = {
      environment = "dev"
    }
  }
}

nat_gateways = {
  "nat-dev" = {
    name                = "nat-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    sku_name            = "Standard"
    tags = {
      environment = "dev"
    }
  }
}

bastions = {
  "bastion-dev" = {
    name                = "bst-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    sku                 = "Basic"
    subnet_key          = "vnet1-bastion_subnet"
    tags = {
      environment = "dev"
    }
  }
}

vpn_gateways = {
  "vnet-gw-dev" = {
    name                = "vnetgw-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    type                = "Vpn"
    vpn_type            = "RouteBased"
    sku                 = "VpnGw1AZ"
    subnet_key          = "vnet1-gateway_subnet"
    tags = {
      environment = "dev"
    }
  }
}

azure_firewalls = {
  "fw-dev" = {
    name                  = "afw-eng-dev-001"
    resource_group_name   = "rg-eng-dev"
    location            = "East US"
    sku_name              = "AZFW_VNet"
    sku_tier              = "Basic"
    subnet_key            = "vnet1-firewall_subnet"
    management_subnet_key = "vnet1-firewall_mgmt_subnet"
    enable_policy         = true
    network_rules = {
      "allow-web-outbound" = {
        name                  = "allow-web-outbound"
        priority              = 100
        action                = "Allow"
        source_addresses      = ["10.0.0.0/16"]
        destination_addresses = ["*"]
        destination_ports     = ["80", "443", "53"]
        protocols             = ["TCP", "UDP"]
      }
    }
    application_rules = {
      "allow-devops-fqdns" = {
        name             = "allow-devops-fqdns"
        priority         = 200
        action           = "Allow"
        source_addresses = ["10.0.0.0/16"]
        target_fqdns = [
          "*.github.com",
          "*.microsoft.com",
          "*.azure.com",
          "*.docker.com",
          "*.docker.io"
        ]
      }
    }
    tags = {
      environment = "dev"
    }
  }
}

nsgs = {
  "nsg-workloads" = {
    name                = "nsg-workloads-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    subnet_key          = "vnet1-vm_subnet"
    security_rules = {
      "allow-internal-vnet-inbound" = {
        name                       = "allow-internal-vnet-inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "10.0.0.0/16"
        destination_address_prefix = "*"
      }
      "deny-public-inbound" = {
        name                       = "deny-public-inbound"
        priority                   = 4000
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
    tags = {
      environment = "dev"
    }
  }
  "nsg-aks" = {
    name                = "nsg-aks-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    subnet_key          = "vnet1-aks_subnet"
    security_rules = {
      "allow-aks-vnet-inbound" = {
        name                       = "allow-aks-vnet-inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "10.0.0.0/16"
        destination_address_prefix = "*"
      }
    }
    tags = {
      environment = "dev"
    }
  }
  "nsg-pe" = {
    name                = "nsg-pe-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    subnet_key          = "vnet1-pe_subnet"
    security_rules = {
      "allow-vnet-pe-inbound" = {
        name                       = "allow-vnet-pe-inbound"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "*"
        source_address_prefix      = "10.0.0.0/16"
        destination_address_prefix = "*"
      }
      "deny-public-pe-inbound" = {
        name                       = "deny-public-pe-inbound"
        priority                   = 4000
        direction                  = "Inbound"
        access                     = "Deny"
        protocol                   = "*"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
    tags = {
      environment = "dev"
    }
  }
}

acrs = {
  "acr-dev" = {
    name                = "acrengdev001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    sku                 = "Premium"
    admin_enabled       = false
    tags = {
      environment = "dev"
    }
  }
}

aks_clusters = {
  "aks-dev" = {
    name                = "aks-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    dns_prefix          = "aksdev"
    sku_tier            = "Standard"
    node_count          = 2
    vm_size             = "Standard_D2s_v7"
    tags = {
      environment = "dev"
    }
  }
}

key_vaults = {
  "kv-dev" = {
    name                          = "kv-eng-dev-001"
    resource_group_name           = "rg-eng-dev"
    location            = "East US"
    sku_name                      = "standard"
    purge_protection_enabled      = true
    public_network_access_enabled = true
    network_acls_default_action   = "Allow"
    tags = {
      environment = "dev"
    }
  }
}

postgresql_servers = {}

cosmosdb_accounts = {}

apim_services = {
  "apim-dev" = {
    name                          = "apim-eng-dev-001"
    resource_group_name           = "rg-eng-dev"
    location            = "East US"
    publisher_name                = "Engenio"
    publisher_email               = "mrajashekhar.reddy@aionos.ai"
    sku_name                      = "Basic_1"
    public_network_access_enabled = true
    tags = {
      environment = "dev"
    }
  }
}

virtual_machines = {
  "vm-ado-agent" = {
    name                = "vm-eng-dev-ado-agent-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
      size                = "Standard_B2ms"
    admin_username      = "azureuser"
    subnet_key          = "vnet1-vm_subnet"
    identity_key        = "uai-vm-dev"
    install_kubectl     = true
    install_az_cli      = true
    tags = {
      environment = "dev"
      role        = "ado-agent"
    }
  }
  "vm-gh-runner-01" = {
    name                = "vm-eng-dev-gh-runner-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
      size                = "Standard_B2ms"
    admin_username      = "azureuser"
    subnet_key          = "vnet1-vm_subnet"
    identity_key        = "uai-vm-dev"
    install_kubectl     = true
    install_az_cli      = true
    tags = {
      environment = "dev"
      role        = "github-runner"
    }
  }
  "vm-gh-runner-02" = {
    name                = "vm-eng-dev-gh-runner-002"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
      size                = "Standard_B2ms"
    admin_username      = "azureuser"
    subnet_key          = "vnet1-vm_subnet"
    identity_key        = "uai-vm-dev"
    install_kubectl     = false
    install_az_cli      = false
    tags = {
      environment = "dev"
      role        = "github-runner"
    }
  }
}

storage_accounts = {
  "stfuncdev" = {
    name                     = "stengdevfunc001"
    resource_group_name      = "rg-eng-dev"
    location            = "East US"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    tags = {
      environment = "dev"
    }
  }
  "stcontainerpool" = {
    name                     = "stengdevcontainerpool001"
    resource_group_name      = "rg-eng-dev"
    location            = "East US"
    account_tier             = "Standard"
    account_replication_type = "LRS"
    tags = {
      environment = "dev"
    }
  }
}

function_apps = {
  "func-dev" = {
    name                = "func-eng-dev-001"
    resource_group_name = "rg-eng-dev"
    location            = "East US"
    storage_account_key = "stfuncdev"
    tags = {
      environment = "dev"
    }
  }
}

entra_external_ids = {}

private_endpoints = {
  "pe-keyvault" = {
    name                  = "pe-kv-eng-dev-001"
    location            = "East US"
    resource_group_name   = "rg-eng-dev"
    subnet_key            = "vnet1-pe_subnet"
    target_type           = "key_vault"
    target_name           = "kv-dev"
    subresource_names     = ["vault"]
    private_dns_zone_name = "privatelink.vaultcore.azure.net"
    vnet_key              = "vnet1"
    tags = {
      environment = "dev"
    }
  }
  "pe-storage-blob" = {
    name                  = "pe-st-eng-dev-001"
    location            = "East US"
    resource_group_name   = "rg-eng-dev"
    subnet_key            = "vnet1-pe_subnet"
    target_type           = "storage_blob"
    target_name           = "stfuncdev"
    subresource_names     = ["blob"]
    private_dns_zone_name = "privatelink.blob.core.windows.net"
    vnet_key              = "vnet1"
    tags = {
      environment = "dev"
    }
  }
  "pe-acr" = {
    name                  = "pe-acr-eng-dev-001"
    location            = "East US"
    resource_group_name   = "rg-eng-dev"
    subnet_key            = "vnet1-pe_subnet"
    target_type           = "acr"
    target_name           = "acr-dev"
    subresource_names     = ["registry"]
    private_dns_zone_name = "privatelink.azurecr.io"
    vnet_key              = "vnet1"
    tags = {
      environment = "dev"
    }
  }
  "pe-aks" = {
    name                  = "pe-aks-eng-dev-001"
    location            = "East US"
    resource_group_name   = "rg-eng-dev"
    subnet_key            = "vnet1-pe_subnet"
    target_type           = "aks"
    target_name           = "aks-dev"
    subresource_names     = ["management"]
    private_dns_zone_name = "privatelink.eastus.azmk8s.io"
    vnet_key              = "vnet1"
    tags = {
      environment = "dev"
    }
  }
}

key_vault_secrets = {
  "vm-admin-password" = {
    name          = "vm-admin-password"
    secret_type   = "random_vm"
    key_vault_key = "kv-dev"
  }
}

role_assignments = {
  "aks-acr-pull" = {
    role_definition_name = "AcrPull"
    principal_type       = "aks"
    principal_key        = "aks-dev"
    scope_type           = "acr"
    scope_key            = "acr-dev"
  }
  "aks-kv-secrets" = {
    role_definition_name = "Key Vault Secrets User"
    principal_type       = "aks"
    principal_key        = "aks-dev"
    scope_type           = "key_vault"
    scope_key            = "kv-dev"
  }
  "func-kv-secrets" = {
    role_definition_name = "Key Vault Secrets User"
    principal_type       = "function_app"
    principal_key        = "func-dev"
    scope_type           = "key_vault"
    scope_key            = "kv-dev"
  }
  "func-storage-blob" = {
    role_definition_name = "Storage Blob Data Contributor"
    principal_type       = "function_app"
    principal_key        = "func-dev"
    scope_type           = "storage_account"
    scope_key            = "stfuncdev"
  }
  "apim-kv-secrets" = {
    role_definition_name = "Key Vault Secrets User"
    principal_type       = "apim"
    principal_key        = "apim-dev"
    scope_type           = "key_vault"
    scope_key            = "kv-dev"
  }
  "vm-uai-kv-secrets" = {
    role_definition_name = "Key Vault Secrets User"
    principal_type       = "user_identity"
    principal_key        = "uai-vm-dev"
    scope_type           = "key_vault"
    scope_key            = "kv-dev"
  }
}
