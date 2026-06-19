/*
resource "azurerm_servicebus_namespace" "example" {
  name                = "dsd-service-bus"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard"

  tags = {
    source = "terraform"
  }
}
*/