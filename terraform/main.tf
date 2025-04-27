locals {
  list_web_app = {
    petstoreapp = "petstoreapp"
  }
  list_web_services = {
    petstoreorderservice   = "petstoreorderservice"
    petstorepetservice     = "petstorepetservice"
    petstoreproductservice = "petstoreproductservice"
  }
}

module "naming" {
  source = "Azure/naming/azurerm"
  suffix = ["ps"]
}

module "resourceGroup" {
  source = "./modules/resourceGroup"

  name     = module.naming.resource_group.name_unique
  location = "eastus"

  depends_on = [
    module.naming
  ]
}

module "userAssignedIdentity" {
  source = "./modules/userAssignedIdentity"

  name                = module.naming.user_assigned_identity.name_unique
  location            = module.resourceGroup.location
  resource_group_name = module.resourceGroup.name

  depends_on = [
    module.naming,
    module.resourceGroup
  ]
}

module "keyVault" {
  source = "./modules/keyVault"

  name                = module.naming.key_vault.name_unique
  location            = module.resourceGroup.location
  resource_group_name = module.resourceGroup.name

  user_assigned_principal_id = module.userAssignedIdentity.principal_id

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.userAssignedIdentity
  ]
}

module "logAnalyticsWorkspace" {
  source = "./modules/logAnalyticsWorkspace"

  name                = module.naming.log_analytics_workspace.name_unique
  location            = module.resourceGroup.location
  resource_group_name = module.resourceGroup.name

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.userAssignedIdentity
  ]
}

module "applicationInsights" {
  source = "./modules/applicationInsights"

  name                = module.naming.application_insights.name_unique
  location            = module.resourceGroup.location
  resource_group_name = module.resourceGroup.name

  workspace_id = module.logAnalyticsWorkspace.id
  key_vault_id = module.keyVault.id

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.logAnalyticsWorkspace,
    module.keyVault,
    module.userAssignedIdentity
  ]
}

module "containerRegistry" {
  source = "./modules/containerRegistry"

  name                = module.naming.container_registry.name_unique
  location            = module.resourceGroup.location
  resource_group_name = module.resourceGroup.name

  user_assigned_id           = module.userAssignedIdentity.id
  user_assigned_principal_id = module.userAssignedIdentity.principal_id

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.userAssignedIdentity
  ]
}

module "containerAppEnvironment" {
  source = "./modules/containerAppEnvironment"

  name                = module.naming.container_app_environment.name_unique
  location            = module.resourceGroup.location
  resource_group_name = module.resourceGroup.name

  log_analytics_workspace_id = module.logAnalyticsWorkspace.id

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.logAnalyticsWorkspace
  ]
}

module "cosmosdb" {
  source = "./modules/cosmosDbAccount"

  name                = module.naming.cosmosdb_account.name_unique
  location            = module.resourceGroup.location
  resource_group_name = module.resourceGroup.name

  user_assigned_id    = module.userAssignedIdentity.id

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.userAssignedIdentity
  ]
}

module "containerAppPetStoreApp" {
  source = "./modules/containerApp"

  name                                        = "${module.naming.app_service_plan.slug}-${local.list_web_app["petstoreapp"]}"
  resource_group_name                         = module.resourceGroup.name
  application_name                            = local.list_web_app["petstoreapp"]
  container_app_environment_id                = module.containerAppEnvironment.id
  container_registry_login_server             = module.containerRegistry.login_server
  key_vault_id                                = module.keyVault.id
  user_assigned_id                            = module.userAssignedIdentity.id
  application_insights_connection_string_name = module.applicationInsights.connection_string_secret_name
  enviroment_variables = merge(
    module.containerAppPetStoreOrderService.env,
    module.containerAppPetstorePetService.env,
    module.containerAppPetStoreProductService.env
  )

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.applicationInsights,
    module.containerAppEnvironment,
    module.containerRegistry,
    module.keyVault,
    module.userAssignedIdentity,
    module.containerAppPetStoreOrderService,
    module.containerAppPetstorePetService,
    module.containerAppPetStoreProductService
  ]
}

module "containerAppPetStoreOrderService" {
  source = "./modules/containerApp"

  name                                        = "${module.naming.app_service_plan.slug}-${local.list_web_services["petstoreorderservice"]}"
  resource_group_name                         = module.resourceGroup.name
  application_name                            = local.list_web_services["petstoreorderservice"]
  container_app_environment_id                = module.containerAppEnvironment.id
  container_registry_login_server             = module.containerRegistry.login_server
  key_vault_id                                = module.keyVault.id
  user_assigned_id                            = module.userAssignedIdentity.id
  application_insights_connection_string_name = module.applicationInsights.connection_string_secret_name
  enviroment_variables = merge(
    module.containerAppPetStoreProductService.env,
    module.cosmosdb.env
  )

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.applicationInsights,
    module.containerAppEnvironment,
    module.containerRegistry,
    module.keyVault,
    module.userAssignedIdentity,
    module.containerAppPetStoreProductService
  ]
}

module "containerAppPetstorePetService" {
  source = "./modules/containerApp"

  name                                        = "${module.naming.app_service_plan.slug}-${local.list_web_services["petstorepetservice"]}"
  resource_group_name                         = module.resourceGroup.name
  application_name                            = local.list_web_services["petstorepetservice"]
  container_app_environment_id                = module.containerAppEnvironment.id
  container_registry_login_server             = module.containerRegistry.login_server
  key_vault_id                                = module.keyVault.id
  user_assigned_id                            = module.userAssignedIdentity.id
  application_insights_connection_string_name = module.applicationInsights.connection_string_secret_name
  enviroment_variables                        = {}

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.applicationInsights,
    module.containerAppEnvironment,
    module.containerRegistry,
    module.keyVault,
    module.userAssignedIdentity,
  ]
}

module "containerAppPetStoreProductService" {
  source = "./modules/containerApp"

  name                                        = "${module.naming.app_service_plan.slug}-${local.list_web_services["petstoreproductservice"]}"
  resource_group_name                         = module.resourceGroup.name
  application_name                            = local.list_web_services["petstoreproductservice"]
  container_app_environment_id                = module.containerAppEnvironment.id
  container_registry_login_server             = module.containerRegistry.login_server
  key_vault_id                                = module.keyVault.id
  user_assigned_id                            = module.userAssignedIdentity.id
  application_insights_connection_string_name = module.applicationInsights.connection_string_secret_name
  enviroment_variables                        = {}

  depends_on = [
    module.naming,
    module.resourceGroup,
    module.applicationInsights,
    module.containerAppEnvironment,
    module.containerRegistry,
    module.keyVault,
    module.userAssignedIdentity,
  ]
}
