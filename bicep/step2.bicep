import * as petLib from 'modules/common.bicep'

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: petLib.resource.containerRegistryName
  params: {
    name: petLib.resource.containerRegistryName
  }
}
