terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.110.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1"
    }
  }

  backend "azurerm" {
    resource_group_name  = "storage-rg"
    storage_account_name = "streamlittfstatedsd"
    container_name       = "terraform"
    #key                  = "strealitpoctfstate.tfstate"
  }

  required_version = ">= 1.8.0"
}

provider "azurerm" {
  features {}
}