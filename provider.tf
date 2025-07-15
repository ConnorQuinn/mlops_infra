terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=4.1.0"
    }
    databricks = {
      source  = "databricks/databricks"
      version = ">=1, <2"
    }
  }
}

provider "azurerm" {
  # The AzureRM Provider supports authenticating using via the Azure CLI, a Managed Identity
  # and a Service Principal. More information on the authentication methods supported by
  # the AzureRM Provider can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure

  # The features block allows changing the behaviour of the Azure Provider, more
  # information can be found here:
  # https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/features-block
  features {}
  subscription_id = "8117f6b2-7314-40cd-aa7f-e65515525681"
}

terraform {
  backend "azurerm" {
    resource_group_name  = "rg_terraform_backend"
    storage_account_name = "strtfbackend"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}   