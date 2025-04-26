# output "name" {
#   value = azurerm_application_insights.applicationInsights.name
# }
#
output "connection_string_secret_name" {
  value = azurerm_key_vault_secret.applicationInsightsConnectionStringSecret.name
}