# mlops_infra
# Usage
- `az login`
- `az account set --subscription "MLOps_subscription"`
- `terraform apply -var-file=dev.tfvars`
- `terraform destroy -var-file=dev.tfvars`
- `export TF_VAR_mlops_..`



- Which region?
- Hub and spoke?



- One subscription containing three environments.
- Environments in separate VNets
- Metastore
- Vnet injected workspaces
- Terraform will not use CI/CD. We will just deploy the infra direct. But then we will use CI/CD for code deployments. 


Below is an example Terraform code snippet to create a self-hosted build agent for GitHub Actions using an Azure Virtual Machine. This setup assumes you are deploying the VM into an existing Azure Virtual Network (VNet).

```hcl
provider "azurerm" {
  features {}
  subscription_id = "your-subscription-id" # Replace with your Azure subscription ID
}

resource "azurerm_resource_group" "build_agent_rg" {
  name     = "rg-build-agent"
  location = "East US" # Replace with your preferred Azure region
}

resource "azurerm_virtual_network" "vnet" {
  name                = "build-agent-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.build_agent_rg.location
  resource_group_name = azurerm_resource_group.build_agent_rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "build-agent-subnet"
  resource_group_name  = azurerm_resource_group.build_agent_rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "build-agent-nic"
  location            = azurerm_resource_group.build_agent_rg.location
  resource_group_name = azurerm_resource_group.build_agent_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "build_agent_vm" {
  name                  = "build-agent-vm"
  location              = azurerm_resource_group.build_agent_rg.location
  resource_group_name   = azurerm_resource_group.build_agent_rg.name
  network_interface_ids = [azurerm_network_interface.nic.id]
  vm_size               = "Standard_B2s" # Adjust based on your workload

  storage_os_disk {
    name              = "build-agent-os-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  os_profile {
    computer_name  = "build-agent"
    admin_username = "azureuser"
    admin_password = "P@ssw0rd1234!" # Replace with a secure password
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  tags = {
    environment = "github-actions"
  }
}

resource "azurerm_public_ip" "public_ip" {
  name                = "build-agent-public-ip"
  location            = azurerm_resource_group.build_agent_rg.location
  resource_group_name = azurerm_resource_group.build_agent_rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "build-agent-nsg"
  location            = azurerm_resource_group.build_agent_rg.location
  resource_group_name = azurerm_resource_group.build_agent_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}
```


## Github actions runner setup
[GitHub Actions Runner setup guide](https://github.com/actions/runner) 
To avoid mucking around with pem keys, I just logged in via the azure terminal. 