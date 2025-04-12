import * as petLib from 'modules/common.bicep'

module logAnalyticsWorkspace 'modules/logAnalyticsWorkspace.bicep' = {
  name: petLib.resource.logAnalyticsWorkspaceName
  params: {
    name: petLib.resource.logAnalyticsWorkspaceName
  }
}

module applicationInsights 'modules/applicationInsights.bicep' = {
  name: petLib.resource.applicationInsightsName
  params: {
    name: petLib.resource.applicationInsightsName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module containerAppEnvironment 'modules/containerAppEnvironment.bicep' = {
  name: petLib.resource.containerAppEnvironmentName
  params: {
    name: petLib.resource.containerAppEnvironmentName
    customerId: logAnalyticsWorkspace.outputs.customerId
    sharedKey: logAnalyticsWorkspace.outputs.primarySharedKey
  }
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' existing = {
  name: petLib.resource.containerRegistryName
}

module applicationServicePlan 'modules/applicationServicePlan.bicep' = {
  name: petLib.resource.applicationServicePlanName
  params: {
    name: petLib.resource.applicationServicePlanName
  }
}

module storageAccounts 'modules/storageAccounts.bicep' = {
  name: petLib.resource.storageAccountsName
  params: {
    name: petLib.resource.storageAccountsName
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

module functionApp 'modules/functionApp.bicep' = {
  name: petLib.resource.functionAppName
  params: {
    name: petLib.resource.functionAppName
    applicationServicePlanId: applicationServicePlan.outputs.id
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    applicationName: 'orderitemsreserver'
    applicationTag: 'v1'
  }
}

module containerAppPetStoreProductService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreProductServiceName
  params: {
    name: petLib.resource.containerAppPetStoreProductServiceName
    applicationName: 'petstoreproductservice'
    applicationTag: 'v1'
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    envVariables: []
  }
}

module containerAppPetStorePetService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStorePetServiceName
  params: {
    name: petLib.resource.containerAppPetStorePetServiceName
    applicationName: 'petstorepetservice'
    applicationTag: 'v1'
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    envVariables: []
  }
}

module containerAppPetStoreOrderService 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreOrderServiceName
  params: {
    name: petLib.resource.containerAppPetStoreOrderServiceName
    applicationName: 'petstoreorderservice'
    applicationTag: 'v1'
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    envVariables: union(containerAppPetStoreProductService.outputs.env, functionApp.outputs.env)
  }
}

module containerAppPetStoreApp 'modules/containerApp.bicep' = {
  name: petLib.resource.containerAppPetStoreAppName
  params: {
    name: petLib.resource.containerAppPetStoreAppName
    applicationName: 'petstoreapp'
    applicationTag: 'v1'
    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
    containerAppEnvironmentId: containerAppEnvironment.outputs.id
    containerRegistryLoginServer: containerRegistry.properties.loginServer
    envVariables: union(
      containerAppPetStoreProductService.outputs.env, 
      containerAppPetStorePetService.outputs.env,
      containerAppPetStoreOrderService.outputs.env,
      functionApp.outputs.env
    )
  }
}
