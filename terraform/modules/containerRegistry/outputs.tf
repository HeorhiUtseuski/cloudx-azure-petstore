output "name" {
  value = azurerm_container_registry.containerRegistry.name
}

output "login_server" {
  value = azurerm_container_registry.containerRegistry.login_server
}
