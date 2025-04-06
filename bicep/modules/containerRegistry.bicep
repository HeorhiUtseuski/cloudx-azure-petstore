import * as petLib from 'common.bicep'

param name string
param location string = resourceGroup().location

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    adminUserEnabled: true
  }
}

//output registryId string = containerRegistry.id
output loginServer string = containerRegistry.properties.loginServer
