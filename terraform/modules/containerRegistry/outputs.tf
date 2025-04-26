output "name" {
  value = azurerm_container_registry.containerRegistry.name
}

output "login_server" {
  value = azurerm_container_registry.containerRegistry.login_server
}

output "admin_username_secret_name" {
  value = azurerm_key_vault_secret.containerRegistryAdminUsernameSecret.name
}

output "admin_password_secret_name" {
  value = azurerm_key_vault_secret.containerRegistryAdminPasswordSecret.name
}