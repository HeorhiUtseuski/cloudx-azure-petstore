param name string

param location string = resourceGroup().location

resource applicationServicePlan 'Microsoft.Web/serverfarms@2024-04-01' = {
  name: name
  location: location
  kind: 'linux'
  sku: {
    tier: 'Dynamic'
    name: 'Y1'
  }
  properties: {
    reserved: true
  }
}

output id string = applicationServicePlan.id
