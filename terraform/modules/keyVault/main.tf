data "azurerm_client_config" "currentClientInfo" {}

resource "azurerm_key_vault" "keyVault" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.currentClientInfo.tenant_id
  sku_name                   = var.sku_name
  purge_protection_enabled   = var.purge_protection_enabled
  soft_delete_retention_days = var.soft_delete_retention_days
}

resource "azurerm_key_vault_access_policy" "keyVaultApplicationAccessPolicy" {
  key_vault_id = azurerm_key_vault.keyVault.id
  tenant_id    = data.azurerm_client_config.currentClientInfo.tenant_id
  object_id    = var.user_assigned_principal_id

  secret_permissions = [
    "Delete", "Get", "List", "Purge", "Set"
  ]
}

resource "azurerm_key_vault_access_policy" "keyVaultPortalAccessPolicy" {
  key_vault_id = azurerm_key_vault.keyVault.id
  tenant_id    = data.azurerm_client_config.currentClientInfo.tenant_id
  object_id    = data.azurerm_client_config.currentClientInfo.object_id

  key_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "Decrypt", "Encrypt",
    "UnwrapKey", "WrapKey", "Verify", "Sign", "Purge", "Release", "Rotate", "GetRotationPolicy", "SetRotationPolicy"
  ]

  secret_permissions = [
    "Get", "List", "Set", "Delete", "Recover", "Backup", "Restore", "Purge"
  ]

  certificate_permissions = [
    "Get", "List", "Update", "Create", "Import", "Delete", "Recover", "Backup", "Restore", "ManageContacts",
    "ManageIssuers", "GetIssuers", "ListIssuers", "SetIssuers", "DeleteIssuers", "Purge"
  ]

  storage_permissions = [
    "Backup", "Delete", "DeleteSAS", "Get", "GetSAS", "List", "ListSAS", "Purge", "Recover", "RegenerateKey",
    "Restore", "Set", "SetSAS", "Update"
  ]
}