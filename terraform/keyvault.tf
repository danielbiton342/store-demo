# azure Key Vault 
resource "azurerm_key_vault" "kv" {
  name                = "kv-storedemo-centralus"
  location            = "centralus"
  resource_group_name = azurerm_resource_group.rg.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enabled_for_deployment          = true
  enabled_for_disk_encryption     = true
  enabled_for_template_deployment = true
  enable_rbac_authorization       = true
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  public_network_access_enabled   = true

  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
    ip_rules       = ["${chomp(data.http.my_ipv4.response_body)}/32"]
  }
  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = azurerm_kubernetes_cluster.aks.identity[0].principal_id
    secret_permissions = [
      "Get",
    ]
  }
}

# Get the built-in Key Vault Secrets User role definition
data "azurerm_role_definition" "kv_secrets_user" {
  name = "Key Vault Secrets User"
}

# Assign Key Vault Secrets User role to AKS
resource "azurerm_role_assignment" "aks_kv_secrets_user" {
  scope              = azurerm_key_vault.kv.id
  role_definition_id = data.azurerm_role_definition.kv_secrets_user.id
  principal_id       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  depends_on         = [azurerm_key_vault.kv]
}

# assign my AAD to key vault
resource "azurerm_role_assignment" "kv_access" {
  principal_id         = var.object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope                = azurerm_key_vault.kv.id
  depends_on           = [azurerm_key_vault.kv]
}
# Storing the output of shared access policies as secrets in azure key vault
resource "azurerm_key_vault_secret" "sender_primary_key" {
  name         = "sender-password"
  value        = azurerm_servicebus_queue_authorization_rule.sender.primary_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_access]
}

resource "azurerm_key_vault_secret" "retreiver_primary_key" {
  name         = "retreiver-password"
  value        = azurerm_servicebus_queue_authorization_rule.retreiver.primary_key
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_access]
}

resource "azurerm_key_vault_secret" "retreiver_amqp_uri" {
  name = "retreiver-uri"
  value = join("", [
    "amqps://",
    azurerm_servicebus_queue_authorization_rule.retreiver.name,
    ":",
    replace(
      replace(
        azurerm_servicebus_queue_authorization_rule.retreiver.primary_key,
        "+",
        "%2B"
      ),
      "=",
      "%3D"
    ),
    "@",
    azurerm_servicebus_namespace.sb_namespace.name,
    ".servicebus.windows.net:5671/?verify=verify_none"
  ])
  key_vault_id = azurerm_key_vault.kv.id
  depends_on   = [azurerm_role_assignment.kv_access]
}
