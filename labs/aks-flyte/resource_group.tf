resource "azurerm_resource_group" "flyte" {
  name     = var.resource_group_name
  location = var.azure_region
}