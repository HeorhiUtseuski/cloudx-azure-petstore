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

resource "azurerm_key_vault_secret" "containerRegistryAdminUsernameSecret" {
  name         = "${var.name}-admin-username"
  value        = azurerm_container_registry.containerRegistry.admin_username
  key_vault_id = var.key_vault_id
}

resource "azurerm_key_vault_secret" "containerRegistryAdminPasswordSecret" {
  name         = "${var.name}-admin-password"
  value        = azurerm_container_registry.containerRegistry.admin_password
  key_vault_id = var.key_vault_id
}