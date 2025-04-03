import * as petLib from 'common.bicep'

var location = resourceGroup().location

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2023-09-01' = {
  name: petLib.generateResourceName('alaw')
  location: location
  properties:{
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: petLib.generateResourceName('aai')
  location: location
  kind: 'java'
  properties: {
    WorkspaceResourceId: logAnalyticsWorkspace.id
    Application_Type: 'java'
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: petLib.generateResourceName('acr')
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-08-02-preview' = {
  name: petLib.generateResourceName('acae')
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: logAnalyticsWorkspace.listKeys().primarySharedKey
      }
    }
  }
}
