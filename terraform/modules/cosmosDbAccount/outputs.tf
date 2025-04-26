output "env" {
  value = {
    "COSMOSDB_CONNECTION_STRING": "AccountEndpoint=${azurerm_cosmosdb_account.cosmosdb.endpoint};AccountKey=${azurerm_cosmosdb_account.cosmosdb.primary_key};"
  }
}