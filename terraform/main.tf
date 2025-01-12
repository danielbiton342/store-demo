resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.rg-location
}

# Get current client configuration
data "azurerm_client_config" "current" {}

# Get my own local pc IP dynamically
data "http" "my_ipv4" {
  url = "http://checkip.amazonaws.com"
}

# azure container registry
resource "azurerm_container_registry" "acr" {
  name                = "myacrdemo"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = true
}


