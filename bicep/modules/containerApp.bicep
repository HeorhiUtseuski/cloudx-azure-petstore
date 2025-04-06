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

resource containerApp 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: name
  location: location
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
      runtime: {
        java: {
          enableMetrics: true
        }
      }
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

output env array = [
  {
    name: '${toUpper(applicatioName)}_URL'
    value: 'https://${containerApp.properties.configuration.ingress.fqdn}'
  }
]
