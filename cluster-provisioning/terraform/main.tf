resource "azurerm_resource_group" "demo" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

resource "azurerm_log_analytics_workspace" "demo" {
  name                = "${var.prefix}-aks-logs"
  location            = "${azurerm_resource_group.demo.location}"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  sku                 = "PerGB2018"
}

resource "azurerm_log_analytics_solution" "demo" {
  solution_name         = "Containers"
  location              = "${azurerm_resource_group.demo.location}"
  resource_group_name   = "${azurerm_resource_group.demo.name}"
  workspace_resource_id = "${azurerm_log_analytics_workspace.demo.id}"
  workspace_name        = "${azurerm_log_analytics_workspace.demo.name}"

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Containers"
  }
}
resource "azurerm_kubernetes_cluster" "demo" {
  name                = "${var.prefix}-aks"
  location            = "${azurerm_resource_group.demo.location}"
  dns_prefix          = "${var.prefix}-aks"
  resource_group_name = "${azurerm_resource_group.demo.name}"
  kubernetes_version  = "${var.kubernetes_version}"

  linux_profile {
    admin_username = "${var.admin_username}"

    ssh_key {
      key_data = "${file(var.public_ssh_key_path)}"
    }
  }

  agent_pool_profile {
    name            = "agentpool"
    count           = "${var.agent_count}"
    vm_size         = "${var.vm_size}"
    os_type         = "Linux"
    os_disk_size_gb = "${var.os_disk_size_gb}"
    type            = "VirtualMachineScaleSets"

    # Required for advanced networking
    vnet_subnet_id = "${var.azure_subnet_id}"
  }


  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      client_app_id     = "${var.aad_client_app_id}"
      server_app_id     = "${var.aad_server_app_id}"
      server_app_secret = "${var.aad_server_app_secret}"
      tenant_id         = "${var.aad_tenant_id}"
    }
  }
  addon_profile {
    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = "${azurerm_log_analytics_workspace.demo.id}"
    }
  }
  network_profile {
    load_balancer_sku  = "standard"
    network_plugin     = "${var.network_plugin}"
    network_policy     = "${var.network_policy}"
    service_cidr       = "${var.service_cidr}"
    dns_service_ip     = "${var.dns_service_ip}"
    docker_bridge_cidr = "${var.docker_bridge_cidr}"
    #pod_cidr = "${var.pod_cidr}"
  }
}