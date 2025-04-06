param name string
param location string =resourceGroup().location

@secure()
param customerId string

@secure()
param sharedKey string


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
