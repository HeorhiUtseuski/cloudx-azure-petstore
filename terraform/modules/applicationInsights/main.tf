resource "azurerm_application_insights" "applicationInsights" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type
  workspace_id        = var.workspace_id
}

resource "azurerm_key_vault_secret" "applicationInsightsConnectionStringSecret" {
  name         = "${var.name}-connection-string"
  value        = azurerm_application_insights.applicationInsights.connection_string
  key_vault_id = var.key_vault_id
}