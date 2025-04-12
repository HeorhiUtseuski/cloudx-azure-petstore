param name string

@secure()
param customerId string

@secure()
param sharedKey string

param location string =resourceGroup().location

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-10-02-preview' = {
  name: name
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: customerId
        sharedKey: sharedKey
      }
    }
  }
}

output id string = containerAppEnvironment.id
