provider "azurerm" {
  version = "=1.34.0"
}

provider "github" {
  token        = "${var.github_token}"
  organization = "${var.github_organization}"
  version      = "=2.2"
}

provider "kubernetes" {
  host                   = "${azurerm_kubernetes_cluster.demo.kube_admin_config.0.host}"
  client_certificate     = "${base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_certificate)}"
  client_key             = "${base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.client_key)}"
  cluster_ca_certificate = "${base64decode(azurerm_kubernetes_cluster.demo.kube_admin_config.0.cluster_ca_certificate)}"
  #version                = "=0.6.0"
  version = "=1.9"
}

provider "tls" {
  version = "=2.1"
}


