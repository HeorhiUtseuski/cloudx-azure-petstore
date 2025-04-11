import * as const from 'common.bicep'

param name string
param applicationServicePlanId string
param containerAppEnvironmentId string
param containerRegistryId string
param containerRegistryLoginServer string
param applicationInsightsConnectionString string
param applicationName string
param storageAccountsName string
@secure()
param storageAccountsAccessKey string

param location string = resourceGroup().location

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  kind: 'functionapp,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    serverFarmId: applicationServicePlanId
    managedEnvironmentId: containerAppEnvironmentId
    httpsOnly: true
    siteConfig: {
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/${applicationName}:latest'
    }
  }
}

resource functionAppAppsettings 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    FUNCTIONS_EXTENSION_VERSION: '~4'
    FUNCTIONS_WORKER_RUNTIME: 'java'
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountsName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountsAccessKey}'
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnectionString
    APPLICATIONINSIGHTS_ROLE_NAME: toLower(applicationName)
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(functionApp.name, containerRegistryId, 'acrpull')
  scope: functionApp
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalType: 'ServicePrincipal'
  }
}

resource developSlot 'Microsoft.Web/sites/slots@2024-04-01' = {
  parent: functionApp
  name: 'develop'
  location: location
  kind: 'functionapp,linux,container'
  identity: {
    type: 'SystemAssigned'
  }
  properties: functionAppAppsettings
}

output env array = [
  {
    name: '${toUpper(applicationName)}_URL'
    value: 'https://${functionApp.name}.azurewebsites.net'
  }
]
