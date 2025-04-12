import * as petLib from 'common.bicep'

param name string
param applicationServicePlanId string
param applicationInsightsConnectionString string
param applicationName string
param applicationTag string

param location string = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' existing = {
  name: petLib.resource.containerRegistryName
}

resource storageAccounts 'Microsoft.Storage/storageAccounts@2024-01-01' existing = {
  name: petLib.resource.storageAccountsName
}

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  kind: 'functionapp,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: applicationServicePlanId
    httpsOnly: true
    siteConfig: {
      acrUseManagedIdentityCreds: true
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/${applicationName}:${applicationTag}'
    }
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.name, containerRegistry.name, 'AcrPull')
  scope: containerRegistry
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalType: 'ServicePrincipal'
  }
}

resource functionAppAppsettings 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'java'
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccounts.listKeys().keys[0].value}'
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnectionString
    APPLICATIONINSIGHTS_ROLE_NAME: toLower(applicationName)
  }

  dependsOn: [
    acrPullRoleAssignment
  ]
}

resource developSlot 'Microsoft.Web/sites/slots@2024-04-01' = {
  parent: functionApp
  name: 'develop'
  location: location
  kind: 'functionapp,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: applicationServicePlanId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistry.properties.loginServer}/${applicationName}:${applicationTag}'
      acrUseManagedIdentityCreds: true
    }
  }

  dependsOn: [
    functionAppAppsettings
  ]
}

resource acrPullRoleAssignmentDevSlot 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(developSlot.name, containerRegistry.name, 'AcrPull')
  scope: containerRegistry
  properties: {
    principalId: developSlot.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalType: 'ServicePrincipal'
  }

  dependsOn: [
    developSlot
  ]
}

resource developSlotAppsettings 'Microsoft.Web/sites/slots/config@2024-04-01' = {
  parent: developSlot
  name: 'appsettings'
  properties: {
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'java'
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccounts.name};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccounts.listKeys().keys[0].value}'
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnectionString
    APPLICATIONINSIGHTS_ROLE_NAME: '${toLower(applicationName)}-develop'
  }

  dependsOn: [
    acrPullRoleAssignmentDevSlot
  ]
}

output env array = [
  {
    name: '${toUpper(applicationName)}_URL'
    value: 'https://${functionApp.name}.azurewebsites.net'
  }
  {
    name: '${toUpper(applicationName)}_DEVELOP_URL'
    value: 'https://${functionApp.name}-${developSlot.name}.azurewebsites.net'
  }
]
