resource "azurerm_network_interface" "nic" {
  name                = "build-agent-nic"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.hub_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "random_password" "admin_password" {
  # note - the password is not exported anywhere so check in the state file if needed.
  length  = 16
  special = true
  upper   = true
  lower   = true
  numeric = true

  # lifecycle {
  #   prevent_destroy = true
  # }
}

# resource "azurerm_virtual_machine" "build_agent_vm" {
#   name                  = "build-agent-vm"
#   location              = azurerm_resource_group.hub_rg.location
#   resource_group_name   = azurerm_resource_group.hub_rg.name
#   network_interface_ids = [azurerm_network_interface.nic.id]
#   vm_size               = "Standard_A1_v2" # Adjust based on your workload

#   storage_os_disk {
#     name              = "build-agent-os-disk"
#     caching           = "ReadWrite"
#     create_option     = "FromImage"
#     managed_disk_type = "Standard_LRS"
#   }

#   storage_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts-gen2"
#     version   = "latest"
#   }

#   os_profile {
#     computer_name  = "build-agent"
#     admin_username = "azureuser"
#     admin_password = random_password.admin_password.result
#   }

#   os_profile_linux_config {
#     disable_password_authentication = false
#   }

#   tags = {
#     environment = "github-actions"
#   }
# }


resource "azurerm_linux_virtual_machine" "build_agent_vm" {
  name                = "build-agent-vm"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  size = "Standard_B1s"
  network_interface_ids = [azurerm_network_interface.nic.id]

  admin_username = "azureuser"

  admin_password = random_password.admin_password.result
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  tags = {
    environment = "github-actions"
  }
}


resource "azurerm_public_ip" "public_ip" {
  name                = "build-agent-public-ip"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_security_group" "nsg" {
  name                = "build-agent-nsg"
  location            = azurerm_resource_group.hub_rg.location
  resource_group_name = azurerm_resource_group.hub_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "81.79.219.136"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}