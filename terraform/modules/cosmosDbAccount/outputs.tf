output "env" {
  value = {
    "AZURE_COSMOS_ENDPOINT": "${azurerm_cosmosdb_account.cosmosdb.endpoint}"
    "AZURE_COSMOS_KEY": "${azurerm_cosmosdb_account.cosmosdb.primary_key}"
    "AZURE_COSMOS_DATABASE": "${azurerm_cosmosdb_sql_database.petstoredb.name}"
  }
}