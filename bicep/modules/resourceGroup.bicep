targetScope='subscription'

param name string


param location string = 'eastus'


resource resourceGroup 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: name
  location: location
}
