import * as const from 'common.bicep'

param name string
param location string = resourceGroup().location
param applicationServicePlanId string
param storageAccountsName string
@secure()
param storageAccountsAccessKey string
@secure()
param applicationInsightsInstrumentationKey string
@secure()
param applicationInsightsConnectionString string

resource functionApp 'Microsoft.Web/sites@2024-04-01' = {
  name: name
  location: location
  kind: 'functionapp'

  identity: {
    type: 'SystemAssigned'
  }

  properties: {
    serverFarmId: applicationServicePlanId
    httpsOnly: true
    reserved: true

    siteConfig: {
      linuxFxVersion: 'Java|17'
    }
  }
}

resource functionAppAppsettings 'Microsoft.Web/sites/config@2024-04-01' = {
  parent: functionApp
  name: 'appsettings'
  properties: {
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountsName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountsAccessKey}'
    WEBSITE_CONTENTAZUREFILECONNECTIONSTRING: 'DefaultEndpointsProtocol=https;AccountName=${storageAccountsName};EndpointSuffix=${environment().suffixes.storage};AccountKey=${storageAccountsAccessKey}'
    APPINSIGHTS_INSTRUMENTATIONKEY: applicationInsightsInstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsightsConnectionString
    FUNCTIONS_WORKER_RUNTIME: 'java'
    FUNCTIONS_EXTENSION_VERSION: '~4'
    WEBSITE_CONTENTSHARE: toLower(storageAccountsName)
  }
}
