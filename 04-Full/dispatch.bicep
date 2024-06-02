import radius as radius

@description('Specifies the Environment Name.')
param environmentName string = 'test'

@description('The Radius Application Name.')
param applicationName string = 'demo04'

@description('The container registry name (leave empty for local deployments).')
param containerRegistry string = 'acrradius.azurecr.io'


var dispatchApiPort = 8080

@description('The k8s namespace name.')
var kubernetesNamespace = '${environmentName}-${applicationName}'

import kubernetes as kubernetes {
  kubeConfig: ''
  namespace: kubernetesNamespace
}

//Deploy shared resources like Jaeger and PubSub
module shared 'shared.bicep' = {
  name: 'shared'
  params: {
    environmentName: environmentName
    applicationName: applicationName
  }
}

// Dispatch API
resource dispatch_api 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'dispatchapi'
  properties: {
    application: shared.outputs.application.id
    environment: shared.outputs.environment.id
    container: {
      image: empty(containerRegistry) ? 'missioncriticaldemo.dispatchapi:latest' : '${containerRegistry}/missioncriticaldemo.dispatchapi:latest'
      imagePullPolicy: empty(containerRegistry) ? 'Never' : 'IfNotPresent'
      env: {
      }
      ports: {
        web: {
          containerPort: dispatchApiPort
          port: dispatchApiPort
        }
      }
    }
    connections: {
      dispatchinboxstate: {
        source: inboxStateStore.id
      }
      dispatchoutboxstate: {
        source: outboxStateStore.id
      }
      gasinstorestate: {
        source: gisStateStore.id
      }
      dispatchpubsub: {
        source: shared.outputs.pubsub.id
      }
      zipkin: {
        source: shared.outputs.jaeger.id
      }
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: 'dispatchapi'
        appPort: dispatchApiPort
        config: daprConfig.metadata.name
      }
      {
        kind: 'kubernetesMetadata'
        annotations: {
          'dapr.io/log-level': 'debug'
        }
      }
    ]
  }
}


// Dapr configuration for telemetry through Jaeger (zipkin endpoint)
resource daprConfig 'dapr.io/Configuration@v1alpha1' = {
  metadata: {
    name: 'dispatchdaprconfig'
    namespace: kubernetesNamespace
  }
  spec: {
    tracing: {
      samplingRate: '1'
      zipkin: {
        endpointAddress: shared.outputs.jaeger.properties.zipkinEndpoint
      }
    }
    metric: {
      enabled: true
    }
  }
}

// Dapr state store for outbox (queryable, managed by Radius)
resource outboxStateStore 'Applications.Dapr/stateStores@2023-10-01-preview' = {
  name: 'outboxstate'
  properties: {
    application: shared.outputs.application.id
    environment: shared.outputs.environment.id
    resourceProvisioning: 'recipe'
    recipe: {
      name: 'localStateStoreRecipe'
      parameters: {
        databaseName: 'dispatch'
        replicaset: true
        appId: 'dispatchapi'
      }
    }
  }
  dependsOn: [
    inboxStateStore
    gisStateStore
  ]
}

// Dapr state store for inbox (queryable, managed by Radius)
resource inboxStateStore 'Applications.Dapr/stateStores@2023-10-01-preview' = {
  name: 'inboxstate'
  properties: {
    application: shared.outputs.application.id
    environment: shared.outputs.environment.id
    resourceProvisioning: 'recipe'
    recipe: {
      name: 'localStateStoreRecipe'
      parameters: {
        databaseName: 'dispatch'
        replicaset: true
        appId: 'dispatchapi'
      }
    }
  }
  dependsOn: [
    gisStateStore
  ]
}

// Dapr state store for gas in store (not queryable, managed by Radius)
resource gisStateStore 'Applications.Dapr/stateStores@2023-10-01-preview' = {
  name: 'gasinstorestate'
  properties: {
    application: shared.outputs.application.id
    environment: shared.outputs.environment.id
    resourceProvisioning: 'recipe'
    recipe: {
      name: 'localStateStoreRecipe'
      parameters: {
        databaseName: 'dispatch'
        replicaset: false
        appId: 'dispatchapi'
      }
    }
  }
}
