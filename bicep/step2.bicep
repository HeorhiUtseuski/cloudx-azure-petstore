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

//module storageAccounts 'modules/storageAccounts.bicep' = {
//  name: petLib.resource.storageAccountsName
//  params: {
//    name: petLib.resource.storageAccountsName
//  }
//}

//module applicationServicePlan 'modules/applicationServicePlanPremium.bicep' = {
//  name: petLib.resource.applicationServicePlanName
//  params: {
//    name: petLib.resource.applicationServicePlanName
//  }
//}

//module functionApp 'modules/functionApp.bicep' = {
//  name: petLib.resource.functionAppName
//  params: {
//    name: petLib.resource.functionAppName
//    applicationServicePlanId: applicationServicePlan.outputs.id
//    storageAccountsName: storageAccounts.outputs.name
//    storageAccountsAccessKey: storageAccounts.outputs.accessKey
//    applicationInsightsInstrumentationKey: applicationInsights.outputs.instrumentationKey
//    applicationInsightsConnectionString: applicationInsights.outputs.connectionString
//  }
//}

module containerRegistry 'modules/containerRegistry.bicep' = {
  name: petLib.resource.containerRegistryName
  params: {
    name: petLib.resource.containerRegistryName
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
