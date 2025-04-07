param name string
param applicatioName string
param applicationInsightsConnectionString string
param containerAppEnvironmentId string
param envVariables array
param containerRegistryLoginServer string

param location string = resourceGroup().location

var BASE_ENV = [
  {
    name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
    value: applicationInsightsConnectionString
  }
  {
    name: 'APPLICATIONINSIGHTS_ROLE_NAME'
    value: toLower(applicatioName)
  }
  {
    name: '${toUpper(applicatioName)}_SERVER_PORT'
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
      registries: [
        {
          server: containerRegistryLoginServer
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: '${name}-cn'
          image: '${containerRegistryLoginServer}/${applicatioName}:latest'
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

resource acrPullRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(name, 'acrpull')
  scope: containerApp
  properties: {
    principalId: containerApp.identity.principalId
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // AcrPull
    principalType: 'ServicePrincipal'
  }
}

output env array = [
  {
    name: '${toUpper(applicatioName)}_URL'
    value: 'https://${containerApp.properties.configuration.ingress.fqdn}'
  }
]
