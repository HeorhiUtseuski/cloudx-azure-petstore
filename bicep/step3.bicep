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

module applicationServicePlan 'modules/applicationServicePlanPremium.bicep' = {
  name: petLib.resource.applicationServicePlanName
  params: {
    name: petLib.resource.applicationServicePlanName
  }
}

module storageAccounts 'modules/storageAccounts.bicep' = {
  name: petLib.resource.storageAccountsName
  params: {
    name: petLib.resource.storageAccountsName
  }
}

module functionApp 'modules/functionAppContainer.bicep' = {
  name: petLib.resource.functionAppName
  params: {
    name: petLib.resource.functionAppName
    applicationServicePlanId: applicationServicePlan.outputs.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    applicationName: 'orderitemsreserver'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    storageAccountsName: storageAccounts.outputs.name
    storageAccountsAccessKey: storageAccounts.outputs.accessKey
  }
}

module containerAppPetStoreProductService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreProductServiceName
  params: {
    name: petLib.resource.containerAppPetStoreProductServiceName
    applicationName: 'petstoreproductservice'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    containerAppEnvironmentId: containerAppEnvironment.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    containerRegistryUserName: containerRegistry.listCredentials().username
    containerRegistryPassword: containerRegistry.listCredentials().passwords[0].value
    envVariables: []
  }
}

module containerAppPetStorePetService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStorePetServiceName
  params: {
    name: petLib.resource.containerAppPetStorePetServiceName
    applicationName: 'petstorepetservice'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    containerAppEnvironmentId: containerAppEnvironment.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    containerRegistryUserName: containerRegistry.listCredentials().username
    containerRegistryPassword: containerRegistry.listCredentials().passwords[0].value
    envVariables: []
  }
}

module containerAppPetStoreOrderService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreOrderServiceName
  params: {
    name: petLib.resource.containerAppPetStoreOrderServiceName
    applicationName: 'petstoreorderservice'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    containerAppEnvironmentId: containerAppEnvironment.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    containerRegistryUserName: containerRegistry.listCredentials().username
    containerRegistryPassword: containerRegistry.listCredentials().passwords[0].value
    envVariables: union(containerAppPetStoreProductService.outputs.env, functionApp.outputs.env)
  }
}

module containerAppPetStoreApp 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreAppName
  params: {
    name: petLib.resource.containerAppPetStoreAppName
    applicationName: 'petstoreapp'
    applicationInsightsConnectionString: applicationInsights.properties.ConnectionString
    containerAppEnvironmentId: containerAppEnvironment.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    containerRegistryUserName: containerRegistry.listCredentials().username
    containerRegistryPassword: containerRegistry.listCredentials().passwords[0].value
    envVariables: union(
      containerAppPetStoreProductService.outputs.env, 
      containerAppPetStorePetService.outputs.env,
      containerAppPetStoreOrderService.outputs.env,
      functionApp.outputs.env
    )
  }
}
