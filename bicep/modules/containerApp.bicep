param name string
param applicationName string
param applicationInsightsConnectionString string
param containerAppEnvironmentId string
param envVariables array
param containerRegistryLoginServer string
@secure()
param containerRegistryUserName string
@secure()
param containerRegistryPassword string

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
      secrets: [
        {
          name: '${toLower(resourceGroup().name)}${toLower(resourceGroup().location)}${toLower(name)}${toLower(applicationName)}'
          value: containerRegistryPassword
        }
      ]
      registries: [
        {
          server: containerRegistryLoginServer
          username: containerRegistryUserName
          passwordSecretRef: '${toLower(resourceGroup().name)}${toLower(resourceGroup().location)}${toLower(name)}${toLower(applicationName)}'
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

output env array = [
  {
    name: '${toUpper(applicationName)}_URL'
    value: 'https://${containerApp.properties.configuration.ingress.fqdn}'
  }
]
