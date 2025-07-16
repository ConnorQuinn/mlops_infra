
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
  name                      = "hub-to-dev"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.dev_vnet.id
}

resource "azurerm_virtual_network_peering" "dev_to_hub" {
  name                      = "dev-to-hub"
  resource_group_name       = azurerm_resource_group.dev_rg.name
  virtual_network_name      = azurerm_virtual_network.dev_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_virtual_network_peering" "hub_to_prod" {
  name                      = "hub-to-prod"
  resource_group_name       = azurerm_resource_group.hub_rg.name
  virtual_network_name      = azurerm_virtual_network.hub_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.prod_vnet.id
}

resource "azurerm_virtual_network_peering" "prod_to_hub" {
  name                      = "prod-to-hub"
  resource_group_name       = azurerm_resource_group.prod_rg.name
  virtual_network_name      = azurerm_virtual_network.prod_vnet.name
  remote_virtual_network_id = azurerm_virtual_network.hub_vnet.id
}

resource "azurerm_subnet" "hub_subnet" {
  name                 = "build-agent-subnet"
  resource_group_name  = azurerm_resource_group.hub_rg.name
  virtual_network_name = azurerm_virtual_network.hub_vnet.name
  address_prefixes     = [var.build_agent_subnet_cidr]
}



############# Dev environment Stuff #############

module "dbx_dev_public_nsg" {
  source              = "git@ssh.dev.azure.com:v3/tf-databricks/tf-databricks/network_security_group?ref=1.0.0"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = var.location
  nsg_name            = local.public_nsg_dev
}

module "dbx_dev_private_nsg" {
  source              = "git@ssh.dev.azure.com:v3/tf-databricks/tf-databricks/network_security_group?ref=1.0.0"
  resource_group_name = azurerm_resource_group.dev_rg.name
  location            = var.location
  nsg_name            = local.private_nsg_dev
}

resource "azurerm_subnet" "dev_infra_subnet" {
  name                 = local.infra_snet_dev
  resource_group_name  = azurerm_resource_group.dev_rg.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  address_prefixes     = [cidrsubnet(var.dev_vnet_cidr, 4, 0)] # 4 newbits gives 16 splits
}

resource "azurerm_subnet" "dbx_dev_public_subnet" {
  name                 = local.public_snet_dev
  resource_group_name  = azurerm_resource_group.dev_rg.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  address_prefixes     = [cidrsubnet(var.dev_vnet_cidr, 4, 1)] # 4 newbits gives 16 splits
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
  delegation {
    name = "dev-${var.application}-public-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      delegation,                         # Optional, if Databricks modifies this
      service_endpoints,                  # Often modified by Databricks
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "dbx_dev_public_nsg_assoc" {
  subnet_id                 = azurerm_subnet.dbx_dev_public_subnet.id
  network_security_group_id = module.dbx_dev_public_nsg.network_security_group_id
}

resource "azurerm_subnet" "dbx_dev_private_subnet" {
  name                 = local.private_snet_dev
  resource_group_name  = azurerm_resource_group.dev_rg.name
  virtual_network_name = azurerm_virtual_network.dev_vnet.name
  address_prefixes     = [cidrsubnet(var.dev_vnet_cidr, 4, 2)] # 4 newbits gives 16 splits
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
  delegation {
    name = "dev-${var.application}-private-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      delegation,                         # Optional, if Databricks modifies this
      service_endpoints,                  # Often modified by Databricks
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "dbx_dev_private_nsg_assoc" {
  subnet_id                 = azurerm_subnet.dbx_dev_private_subnet.id
  network_security_group_id = module.dbx_dev_private_nsg.network_security_group_id
}




############# Prod environment Stuff #############

module "dbx_prod_public_nsg" {
  source              = "git@ssh.dev.azure.com:v3/tf-databricks/tf-databricks/network_security_group?ref=1.0.0"
  resource_group_name = azurerm_resource_group.prod_rg.name
  location            = var.location
  nsg_name            = local.public_nsg_prod
}

module "dbx_prod_private_nsg" {
  source              = "git@ssh.dev.azure.com:v3/tf-databricks/tf-databricks/network_security_group?ref=1.0.0"
  resource_group_name = azurerm_resource_group.prod_rg.name
  location            = var.location
  nsg_name            = local.private_nsg_prod
}

resource "azurerm_subnet" "prod_infra_subnet" {
  name                 = local.infra_snet_prod
  resource_group_name  = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  address_prefixes     = [cidrsubnet(var.prod_vnet_cidr, 4, 0)] # 4 newbits gives 16 splits
}

resource "azurerm_subnet" "dbx_prod_public_subnet" {
  name                 = local.public_snet_prod
  resource_group_name  = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  address_prefixes     = [cidrsubnet(var.prod_vnet_cidr, 4, 1)] # 4 newbits gives 16 splits
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
  delegation {
    name = "prod-${var.application}-public-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      delegation,                         # Optional, if Databricks modifies this
      service_endpoints,                  # Often modified by Databricks
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "dbx_prod_public_nsg_assoc" {
  subnet_id                 = azurerm_subnet.dbx_prod_public_subnet.id
  network_security_group_id = module.dbx_prod_public_nsg.network_security_group_id
}

resource "azurerm_subnet" "dbx_prod_private_subnet" {
  name                 = local.private_snet_prod
  resource_group_name  = azurerm_resource_group.prod_rg.name
  virtual_network_name = azurerm_virtual_network.prod_vnet.name
  address_prefixes     = [cidrsubnet(var.prod_vnet_cidr, 4, 2)] # 4 newbits gives 16 splits
  service_endpoints    = ["Microsoft.Storage", "Microsoft.KeyVault", "Microsoft.Sql"]
  
  delegation {
    name = "prod-${var.application}-private-delegation"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action",
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"
      ]
    }
  }

  lifecycle {
    ignore_changes = [
      delegation,                         # Optional, if Databricks modifies this
      service_endpoints,                  # Often modified by Databricks
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "dbx_prod_private_nsg_assoc" {
  subnet_id                 = azurerm_subnet.dbx_prod_private_subnet.id
  network_security_group_id = module.dbx_prod_private_nsg.network_security_group_id
}
