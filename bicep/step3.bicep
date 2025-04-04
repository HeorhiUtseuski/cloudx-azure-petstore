import * as petLib from 'common.bicep'

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: petLib.generateResourceName('aai')
}

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' existing = {
  name: petLib.generateResourceName('acr')
}

resource containerAppEnvironment 'Microsoft.App/managedEnvironments@2024-08-02-preview' existing = {
  name: petLib.generateResourceName('acae')
}

resource containerAppWeb 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: petLib.generateResourceName('acaw')
  location: petLib.location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      secrets: [
        {
          name: petLib.generateResourceName('acaprs')
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: petLib.generateResourceName('acaprs')
        }
      ]
      activeRevisionsMode: petLib.revisionMode
      ingress: {
        allowInsecure: true
        external: true
        transport: 'auto'
        targetPort: 8080
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
          name: petLib.generateResourceName('acawc')
          image: '${containerRegistry.properties.loginServer}/petstoreapp:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'PETSTOREAPP_SERVER_PORT'
              value: '8080'
            }
            {
              name: 'PETSTOREORDERSERVICE_URL'
              value: 'https://${containerAppOrderService.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'PETSTOREPETSERVICE_URL'
              value: 'https://${containerAppPetService.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'PETSTOREPRODUCTSERVICE_URL'
              value: 'https://${containerAppProductService.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsights.properties.ConnectionString
            }
            {
              name: 'APPLICATIONINSIGHTS_ROLE_NAME'
              value: 'petstoreapp'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
        rules: [
          {
            name: petLib.generateResourceName('httpscalerule')
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

resource containerAppOrderService 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: petLib.generateResourceName('acao')
  location: petLib.location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      secrets: [
        {
          name: petLib.generateResourceName('acaprs')
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: petLib.generateResourceName('acaprs')
        }
      ]
      activeRevisionsMode: petLib.revisionMode
      ingress: {
        allowInsecure: true
        external: true
        transport: 'auto'
        targetPort: 8080
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
          name: petLib.generateResourceName('acaoc')
          image: '${containerRegistry.properties.loginServer}/petstoreorderservice:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'PETSTOREORDERSERVICE_SERVER_PORT'
              value: '8080'
            }
            {
              name: 'PETSTOREPRODUCTSERVICE_URL'
              value: 'https://${containerAppProductService.properties.configuration.ingress.fqdn}'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsights.properties.ConnectionString
            }
            {
              name: 'APPLICATIONINSIGHTS_ROLE_NAME'
              value: 'petstoreorderservice'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
        rules: [
          {
            name: petLib.generateResourceName('httpscalerule')
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

resource containerAppPetService 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: petLib.generateResourceName('acape')
  location: petLib.location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      secrets: [
        {
          name: petLib.generateResourceName('acaprs')
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: petLib.generateResourceName('acaprs')
        }
      ]
      activeRevisionsMode: petLib.revisionMode
      ingress: {
        allowInsecure: true
        external: true
        transport: 'auto'
        targetPort: 8080
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
          name: petLib.generateResourceName('acapec')
          image: '${containerRegistry.properties.loginServer}/petstorepetservice:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'PETSTOREPETSERVICE_SERVER_PORT'
              value: '8080'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsights.properties.ConnectionString
            }
            {
              name: 'APPLICATIONINSIGHTS_ROLE_NAME'
              value: 'petstorepetservice'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
        rules: [
          {
            name: petLib.generateResourceName('httpscalerule')
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}

resource containerAppProductService 'Microsoft.App/containerApps@2024-10-02-preview' = {
  name: petLib.generateResourceName('acapr')
  location: petLib.location
  properties: {
    environmentId: containerAppEnvironment.id
    configuration: {
      secrets: [
        {
          name: petLib.generateResourceName('acaprs')
          value: containerRegistry.listCredentials().passwords[0].value
        }
      ]
      registries: [
        {
          server: containerRegistry.properties.loginServer
          username: containerRegistry.listCredentials().username
          passwordSecretRef: petLib.generateResourceName('acaprs')
        }
      ]
      activeRevisionsMode: petLib.revisionMode
      ingress: {
        allowInsecure: true
        external: true
        transport: 'auto'
        targetPort: 8080
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
          name: petLib.generateResourceName('acaprc')
          image: '${containerRegistry.properties.loginServer}/petstoreproductservice:latest'
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'PETSTOREPRODUCTSERVICE_SERVER_PORT'
              value: '8080'
            }
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: applicationInsights.properties.ConnectionString
            }
            {
              name: 'APPLICATIONINSIGHTS_ROLE_NAME'
              value: 'petstoreproductservice'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 3
        rules: [
          {
            name: petLib.generateResourceName('httpscalerule')
            http: {
              metadata: {
                concurrentRequests: '10'
              }
            }
          }
        ]
      }
    }
  }
}
