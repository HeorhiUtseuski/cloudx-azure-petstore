import * as petLib from 'common.bicep'

param name string
param applicationName string
param applicationTag string
param applicationInsightsConnectionString string
param containerAppEnvironmentId string
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

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2024-11-01-preview' existing = {
  name: petLib.resource.containerRegistryName
}

resource containerApp 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: name
  location: location
  properties: {
    environmentId: containerAppEnvironmentId
    configuration: {
      registries: [
        {
          server: containerRegistryLoginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: '${name}-admin-password'
        }
      ]
      secrets: [
        {
          name: '${name}-admin-password'
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      activeRevisionsMode: 'Single'
      ingress: {
        external: true
        transport: 'auto'
        allowInsecure: true
        targetPort: 8080
        //traffic: [
        //  {
        //    latestRevision: true
        //    weight: 100
        //  }
        //]
      }
      
    }
    template: {
      containers: [
        {
          name: '${name}-cn'
          image: '${containerRegistryLoginServer}/${applicationName}:${applicationTag}'
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
