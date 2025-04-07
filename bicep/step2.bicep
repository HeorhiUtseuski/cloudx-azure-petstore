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
