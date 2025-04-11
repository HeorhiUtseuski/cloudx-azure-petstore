import * as petLib from 'common.bicep'

param name string
param logAnalyticsWorkspaceId string

param location string = resourceGroup().location
param kind string = 'java'
param kindWorkspace string = 'java'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: kind
  properties: {
    WorkspaceResourceId: logAnalyticsWorkspaceId
    Application_Type: kindWorkspace
  }
}

//output instrumentationKey string = applicationInsights.properties.InstrumentationKey
output connectionString string = applicationInsights.properties.ConnectionString
