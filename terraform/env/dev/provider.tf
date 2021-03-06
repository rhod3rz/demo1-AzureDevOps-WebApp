terraform {
  required_version = "1.2.2"                                  /* Version pin terraform; test upgrades */
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.9.0"                                       /* Version pin provider (https://releases.hashicorp.com/); test upgrades */
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "2.22.0"
    }
  }
  backend "azurerm" {
    storage_account_name  = "sadlterraformstate210713"        /**** UPDATE HERE ****/
    container_name        = "tfstate-dev"                     /**** UPDATE HERE ****/
    key                   = "220606-1000-todolist.tfstate"    /**** UPDATE HERE ****/
    # access_key          = Use $env:ARM_ACCESS_KEY or ARM_ACCESS_KEY if bash
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  client_id       = "2aa9eba7-3055-4546-b8f2-ce10f98981d2"
  subscription_id = "2bc7b65e-18d6-42ae-afb2-e66d50be6b05"
  tenant_id       = "73578441-dc3d-4ecd-a298-fc5c6f40e191"
  # client_secret = Use $env:ARM_CLIENT_SECRET or ARM_CLIENT_SECRET if bash
}

provider "azuread" {
  client_id       = "2aa9eba7-3055-4546-b8f2-ce10f98981d2"
  tenant_id       = "73578441-dc3d-4ecd-a298-fc5c6f40e191"
  # client_secret = Use $env:ARM_CLIENT_SECRET or ARM_CLIENT_SECRET if bash
}
