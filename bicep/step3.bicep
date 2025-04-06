import * as petLib from 'modules/common.bicep'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: petLib.resource.applicationInsightsName
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-10-02-preview' existing = {
  name: petLib.resource.containerAppEnvironmentName
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' existing = {
  name: petLib.resource.containerRegistryName
}

module containerAppPetStoreProductService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreProductServiceName
  params: {
    name: petLib.resource.containerAppPetStoreProductServiceName
    applicatioName: 'petstoreproductservice'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    containerAppEnvironmentId: containerAppEnvironment.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    envVariables: []
  }
}

module containerAppPetStorePetService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStorePetServiceName
  params: {
    name: petLib.resource.containerAppPetStorePetServiceName
    applicatioName: 'petstorepetservice'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    containerAppEnvironmentId: containerAppEnvironment.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    envVariables: []
  }
}

module containerAppPetStoreOrderService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreOrderServiceName
  params: {
    name: petLib.resource.containerAppPetStoreOrderServiceName
    applicatioName: 'petstoreorderservice'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    containerAppEnvironmentId: containerAppEnvironment.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    envVariables: union(containerAppPetStoreProductService.outputs.env, [])
  }
}

module containerAppPetStoreApp 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreAppName
  params: {
    name: petLib.resource.containerAppPetStoreAppName
    applicatioName: 'petstoreapp'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    containerAppEnvironmentId: containerAppEnvironment.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    envVariables: union(
      containerAppPetStoreProductService.outputs.env, 
      containerAppPetStorePetService.outputs.env,
      containerAppPetStoreOrderService.outputs.env
      )
  }
}
