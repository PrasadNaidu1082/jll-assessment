variable "resource_group_name" {
  description = "The name of the resource group"
  type        = string
  default = "rg-jll-challenge"
}

variable "cluster_name" {
  description = "The name of the AKS cluster."
  type        = string
  default = "aks-jll-challenge"
}

variable "location" {
  description = "The Azure region"
  type        = string
  default = "South India"
}


variable "kubernetes_version" {
  description = "The Azure region"
  type        = string
  default = "1.29"
}

variable "appId" {
  description = "Azure Kubernetes Service Cluster service principal"
}

variable "password" {
  description = "Azure Kubernetes Service Cluster password"
}
