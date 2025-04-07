import * as const from 'common.bicep'

param name string
param location string = resourceGroup().location
param applicationServicePlanId string
param containerRegistryLoginServer string
param applicationName string
param storageAccountsName string
@secure()
param storageAccountsAccessKey string

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
      linuxFxVersion: 'DOCKER|${containerRegistryLoginServer}/${applicationName}:latest'
    }
  }
}

resource functionAppAppsettings 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    FUNCTIONS_WORKER_RUNTIME: 'java'
    WEBSITES_ENABLE_APP_SERVICE_STORAGE: 'false'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountsName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountsAccessKey}'
  }
}

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(name, 'acrpull')
  scope: functionApp
  properties: {
    principalId: functionApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalType: 'ServicePrincipal'
  }
}

output env array = [
  {
    name: '${toUpper(applicationName)}_URL'
    value: 'https://${functionApp.name}.azurewebsites.net'
  }
]
