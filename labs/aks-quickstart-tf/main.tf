variable "resource_group_location" {
  type        = string
  default     = "eastus"
  description = "Location of the resource group."
}

variable "resource_group_name" {
  type        = string
  default     = "lab-aks-quickstart-tf"
  description = "Name of the resource group"
}

variable "aks_prefix_name" {
  type        = string
  default     = "aks"
  description = "Prefix of the aks resource name that will be combined with a random ID so name is unique in your Azure subscription"
}

variable "aks_nodepool_count" {
  type        = number
  description = "The initial quantity of nodes for the node pool."
  default     = 3
}

variable "aks_nodepool_vm_size" {
  type        = string
  description = "The sku for the VM's in the nodepool."
  default     = "Standard_D2_v2"
}

resource "azurerm_resource_group" "rg" {
  location = var.resource_group_location
  name     = var.resource_group_name
}

resource "random_pet" "azurerm_kubernetes_cluster_name" {
    prefix = var.aks_prefix_name
}

resource "random_pet" "azurerm_kubernetes_cluster_dns_prefix" {
  prefix = "dns"
}

resource "azurerm_kubernetes_cluster" "k8s" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  name                = random_pet.azurerm_kubernetes_cluster_name.id
  dns_prefix          = random_pet.azurerm_kubernetes_cluster_dns_prefix.id

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = var.aks_nodepool_vm_size
    node_count = var.aks_nodepool_count
  }
  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.k8s.name
}

output "host" {
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
  sensitive = true
}

