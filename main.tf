##### HUB STUFF #####

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
  enable_rbac_authorization   = true 
}


# resource "azuread_application" "databricks_mlops_sp" {
#   display_name = "databricks-mlops-sp"
# }

# resource "azuread_service_principal" "databricks_mlops_sp" {
#   client_id = azuread_application.databricks_mlops_sp.application_id
# }


##### DEV STUFF #####


resource "azurerm_databricks_workspace" "dev_workspace" {
  name                = local.databricks_workspace_dev
  location            = var.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  sku                 = "premium"

  custom_parameters { # VNet Injection
    no_public_ip                                         = true
    public_subnet_name                                   = azurerm_subnet.dbx_dev_public_subnet.name
    private_subnet_name                                  = azurerm_subnet.dbx_dev_private_subnet.name
    virtual_network_id                                   = azurerm_virtual_network.dev_vnet.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.dbx_dev_public_nsg_assoc.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.dbx_dev_private_nsg_assoc.id
  }
}

resource "azurerm_storage_account" "dev_storage" {
  name                     = local.adls_name_dev
  resource_group_name      = azurerm_resource_group.dev_rg.name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = "true"
  tags                     = local.tags
}

resource "azurerm_databricks_access_connector" "ucac_dev" {
  name = local.ucac_dev
  location = var.location
  resource_group_name = azurerm_resource_group.dev_rg.name
  identity {
    type = "SystemAssigned"
  }
  tags = local.tags
}


resource "azurerm_role_assignment" "ucac_storage_role_dev" {
  scope = azurerm_storage_account.dev_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = azurerm_databricks_access_connector.ucac_dev.identity[0].principal_id
}

##### PROD STUFF #####


resource "azurerm_databricks_workspace" "prod_workspace" {
  name                = local.databricks_workspace_prod
  location            = var.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  sku                 = "premium"

  custom_parameters { # VNet Injection
    no_public_ip                                         = true
    public_subnet_name                                   = azurerm_subnet.dbx_prod_public_subnet.name
    private_subnet_name                                  = azurerm_subnet.dbx_prod_private_subnet.name
    virtual_network_id                                   = azurerm_virtual_network.prod_vnet.id
    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.dbx_prod_public_nsg_assoc.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.dbx_prod_private_nsg_assoc.id
  }
}

resource "azurerm_storage_account" "prod_storage" {
  name                     = local.adls_name_prod
  resource_group_name      = azurerm_resource_group.prod_rg.name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  is_hns_enabled           = "true"
  tags                     = local.tags
}


resource "azurerm_databricks_access_connector" "ucac_prod" {
  name = local.ucac_prod
  location = var.location
  resource_group_name = azurerm_resource_group.prod_rg.name
  identity {
    type = "SystemAssigned"
  }
  tags = local.tags
}


resource "azurerm_role_assignment" "ucac_storage_role_prod" {
  scope = azurerm_storage_account.prod_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id = azurerm_databricks_access_connector.ucac_prod.identity[0].principal_id
}
