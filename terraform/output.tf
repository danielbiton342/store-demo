output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw

  sensitive = true
}
# Out put shared access policies keys from service bus queue
output "servicebus_queue_retreiver_primary_key" {
  value     = azurerm_servicebus_queue_authorization_rule.retreiver.primary_key
  sensitive = true
}
output "service_bus_queue_retreiver_amqps_uri" {
  value     = azurerm_servicebus_queue_authorization_rule.retreiver.secondary_connection_string
  sensitive = true
}
output "service_bus_queue_sender_primary_key" {
  value     = azurerm_servicebus_queue_authorization_rule.sender.primary_key
  sensitive = true
}

# acr login server
output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

# aks public IP 
output "aks_public_ip" {
  value     = data.azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive = true
}
