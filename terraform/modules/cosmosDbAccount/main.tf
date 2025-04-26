resource "azurerm_cosmosdb_account" "cosmosdb" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  offer_type          = var.offer_type
  kind                = var.kind

  consistency_policy {
    consistency_level = var.consistency_level
  }

  geo_location {
    location          = "eastus2"
    failover_priority = 0
  }

  capabilities {
    name = "EnableServerless"
  }

  free_tier_enabled = true

  identity {
    type = "UserAssigned"
    identity_ids = [var.user_assigned_id]
  }
}

resource "azurerm_cosmosdb_sql_database" "petstoredb" {
  name                = "petstore"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
}

resource "azurerm_cosmosdb_sql_container" "orders" {
  name                = "orders"
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.cosmosdb.name
  database_name       = azurerm_cosmosdb_sql_database.petstoredb.name

  partition_key_paths = ["/orderId"]
}