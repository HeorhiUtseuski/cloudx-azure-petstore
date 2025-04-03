targetScope='subscription'

param resourceGroupName string

@allowed([
  'eastus'
  'westeurope'
])
param location string = 'westeurope'

resource petStoreArg 'Microsoft.Resources/resourceGroups@2024-07-01' = {
  name: resourceGroupName
  location: location
}
