# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "lms-rg"
  location = "East US"
}