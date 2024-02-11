provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.cluster_name
  kubernetes_version  = var.kubernetes_version 
  node_resource_group = azurerm_resource_group.aks_rg.name

  default_node_pool {
    name            = "default"
    node_count      = 2
    vm_size         = "Standard_DS2_v2"
  }

    service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  tags = {
    environment = "production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw

  sensitive = true
}

provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.aks_cluster.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.aks_cluster.kube_config[0].cluster_ca_certificate)
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = "argocd"
  version    = "2.10.0"

  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }
}