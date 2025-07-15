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

resource "azurerm_virtual_network" "hub_vnet" {
  name                = "hub-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  address_space       = [var.hub_vnet_cidr]
}

resource "azurerm_virtual_network" "dev_vnet" {
  name                = "dev-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  address_space       = [var.dev_vnet_cidr]
}

resource "azurerm_virtual_network" "prod_vnet" {
  name                = "prod-vnet"
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  address_space       = [var.prod_vnet_cidr]
}

resource "azurerm_virtual_network_peering" "hub_to_dev" {
  name = "hub-to-dev"
  resource_group_name = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.dev_vnet.id
}

resource "azurerm_virtual_network_peering" "dev_to_hub" {
  name = "dev-to-hub"
  resource_group_name = azurerm_resource_group.dev_rg.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_virtual_network_peering" "hub_to_prod" {
  name = "hub-to-prod"
  resource_group_name = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.prod_vnet.id
}

resource "azurerm_virtual_network_peering" "prod_to_hub" {
  name = "prod-to-hub"
  resource_group_name = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

