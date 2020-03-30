provider "azurerm" {
  version = "=2.2.0"
  features {}
}

provider "github" {
  token        = var.github_token
  organization = var.github_organization
  version      = "=2.4.1"
}

provider "kubernetes" {
  host                   = azurerm_kubernetes_cluster.demo.kube_admin_config.0.host
  client_certificate     = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_certificate)
  client_key             = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_key)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.cluster_ca_certificate)
  #version                = "=0.6.0"
  version = "=1.11.1"
}

provider "tls" {
  version = "=2.1"
}


