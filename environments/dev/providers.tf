terraform {
  required_version = ">= 1.3.0"

  backend "azurerm" {
    resource_group_name  = "rg-eng-dev-tfstate"
    storage_account_name = "stengdevterraformstate"
    container_name       = "tfstate"
    key                  = "dev.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.117.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}
