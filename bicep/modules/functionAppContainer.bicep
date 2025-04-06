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

output env array = [
  {
    name: '${toUpper(applicationName)}_URL'
    value: 'https://${functionApp.name}.azurewebsites.net'
  }
]
