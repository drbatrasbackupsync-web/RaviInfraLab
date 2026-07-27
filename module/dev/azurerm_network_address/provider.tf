terraform {
  required_version = ">= 1.0.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "tf-state-rg"
    storage_account_name = "mystorageaccounttf456"
    container_name       = "tfstate"
    key                  = "network_interface-chor-dev.tfstate"
  }
}

provider "azurerm" {
  features {}
}
