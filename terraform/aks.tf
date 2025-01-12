data "azurerm_kubernetes_cluster" "aks" {
  name                = azurerm_kubernetes_cluster.aks.name
  resource_group_name = azurerm_resource_group.rg.name
}


# azure kubernetes service AKS
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "myAKSCluster"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.dns_prefix

  sku_tier = "Free"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                  = "nodepool1"
    node_count            = 2
    vm_size               = "Standard_DS2_v2"
    os_disk_size_gb       = 128
    os_disk_type          = "Managed"
    type                  = "VirtualMachineScaleSets"
    orchestrator_version  = "1.30.6"
    max_pods              = 250
    enable_node_public_ip = false
    enable_auto_scaling   = false
    os_sku                = "Ubuntu" # Changed from os_type
    node_labels           = {}
  }

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "Overlay"
    load_balancer_sku   = "standard"
    outbound_type       = "loadBalancer"

    load_balancer_profile {
      managed_outbound_ip_count = 1
    }

    pod_cidr           = "10.244.0.0/16"
    service_cidr       = "10.0.0.0/16"
    dns_service_ip     = "10.0.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = var.sshkey
    }
  }
  azure_policy_enabled = true                        # Changed from addon_profile.azure_policy
  azure_active_directory_role_based_access_control { # Changed from enable_rbac
    managed            = true
    azure_rbac_enabled = true
  }
  key_vault_secrets_provider {
    secret_rotation_enabled = true
  }
  storage_profile {
    blob_driver_enabled         = true # Added as per latest schema
    disk_driver_enabled         = true # Changed from disk_csi_driver
    file_driver_enabled         = true # Changed from file_csi_driver
    snapshot_controller_enabled = true # Changed from snapshot_controller
  }

  automatic_channel_upgrade = "node-image" # Changed from auto_upgrade_profile

  oidc_issuer_enabled = true # Changed from oidc_issuer_profile

  tags = {
    Environment = "Production"
  }
}

# Role Assignment for Admin Access
resource "azurerm_role_assignment" "aks_admin" {
  principal_id         = data.azurerm_client_config.current.object_id
  role_definition_name = "Azure Kubernetes Service RBAC Cluster Admin"
  scope                = azurerm_kubernetes_cluster.aks.id

  depends_on = [azurerm_kubernetes_cluster.aks]
}

# role assignment for AKS to ACR
resource "azurerm_role_assignment" "aks_role_assignment" {
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = azurerm_container_registry.acr.id
  skip_service_principal_aad_check = true
}


