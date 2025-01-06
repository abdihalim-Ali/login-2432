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
