resource "azurerm_resource_group" "resourceGroup" {
  name     = var.name
  location = var.location

  lifecycle {
    prevent_destroy = false
  }
}