# azure service bus namespace
resource "azurerm_servicebus_namespace" "sb_namespace" {
  name                          = "sb-store-demo-114"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  sku                           = "Basic"
  minimum_tls_version           = "1.2"
  public_network_access_enabled = true

  tags = {
    source = "terraform"
  }
}

# azure service bus QUEUE
resource "azurerm_servicebus_queue" "orders_queue" {
  name         = "orders"
  namespace_id = azurerm_servicebus_namespace.sb_namespace.id

}
# Shared access policy keys
resource "azurerm_servicebus_queue_authorization_rule" "sender" {
  name     = "sender"
  queue_id = azurerm_servicebus_queue.orders_queue.id

  listen = false
  send   = true
  manage = false
}
resource "azurerm_servicebus_queue_authorization_rule" "retreiver" {
  name     = "retreiver"
  queue_id = azurerm_servicebus_queue.orders_queue.id

  listen = true
  send   = false
  manage = false
}
