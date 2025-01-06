# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "lms-rg"
  location = "East US"
}

# Create a virtual network 
resource "azurerm_virtual_network" "lms" {
  name                = "lms-vnet"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  address_space       = ["10.0.0.0/16"]
}

# Frontend Subnet
resource "azurerm_subnet" "lms-fe-sn" {
  name                 = "fronten-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.lms.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Frontend Subnet
resource "azurerm_subnet" "lms-be-sn" {
  name                 = "backend-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.lms.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Frontend Subnet
resource "azurerm_subnet" "lms-db-sn" {
  name                 = "database-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.lms.name
  address_prefixes     = ["10.0.3.0/24"]
}

# Public IP
resource "azurerm_public_ip" "fe-pip" {
  name                = "frontend-ip"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
} 

# NIC
resource "azurerm_network_interface" "fe-nic" {
  name                = "fromtend-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.lms-fe-sn.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.fe-pip.id
  }
}

# VM
resource "azurerm_linux_virtual_machine" "fe-vm" {
  name                = "frontend-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "ubuntu"
  custom_data         = filebase64("script.sh")
  network_interface_ids = [
    azurerm_network_interface.fe-nic.id,
  ]

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}