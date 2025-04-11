param name string
param applicationName string
param applicationInsightsConnectionString string
param containerAppEnvironmentId string
param containerRegistryId string
param containerRegistryLoginServer string
param envVariables array

param location string = resourceGroup().location

var BASE_ENV = [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsightsConnectionString
  }
  {
    name: 'APPLICATIONINSIGHTS_ROLE_NAME'
    value: toLower(applicationName)
  }
  {
    name: '${toUpper(applicationName)}_SERVER_PORT'
    value: '8080'
  }
]

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerAppEnvironmentId
    configuration: {
      registries: [
        {
          server: containerRegistryLoginServer
          identity: 'SystemAssigned'
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        targetPort: 8080
        transport: 'auto'
        allowInsecure: true
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      containers: [
        {
          name: '${name}-cn'
          image: '${containerRegistryLoginServer}/${applicationName}:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: union(BASE_ENV, envVariables)
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
        rules: [
          {
            name: 'pet-http-rule'
            http: {
              metadata: {
                concurrentRequests: '50'
              }
            }
          }
        ]
      }
    }
  }
}

resource acrPullRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(containerApp.name, containerRegistryId, 'acrpull')
  scope: containerApp
  properties: {
    principalId: containerApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalType: 'ServicePrincipal'
  }
}

output env array = [
  {
    name: '${toUpper(applicationName)}_URL'
    value: 'https://${containerApp.properties.configuration.ingress.fqdn}'
  }
]
