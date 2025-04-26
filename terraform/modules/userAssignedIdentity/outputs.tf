output "id" {
  value = azurerm_user_assigned_identity.userAssignedIdentity.id
}

output "principal_id" {
  value = azurerm_user_assigned_identity.userAssignedIdentity.principal_id
}