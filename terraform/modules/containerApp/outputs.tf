output "env" {
  value = {
    "${upper(var.application_name)}_URL": "https://${azurerm_container_app.containerApp.ingress[0].fqdn}"
  }
}