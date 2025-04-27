resource "azurerm_container_registry" "containerRegistry" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  admin_enabled       = var.admin_enabled

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_id]
  }
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.containerRegistry.id
  role_definition_name = "AcrPull"
  principal_id         = var.user_assigned_principal_id
}