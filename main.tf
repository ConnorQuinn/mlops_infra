resource "azurerm_resource_group" "hub_rg" {
  name     = local.hub_rg_name
  location = var.location
}

resource "azurerm_resource_group" "dev_rg" {
  name     = local.dev_rg_name
  location = var.location
}

resource "azurerm_resource_group" "prod_rg" {
  name     = local.prod_rg_name
  location = var.location
}

resource "azurerm_key_vault" "kv" {
  name                = local.keyvault_name
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
}

