// Shared services like Zipkin and Pub/Sub are defined here. Used from Dispatch and Plant APIs.

import radius as radius

@description('Specifies the Environment Name.')
param environmentName string = 'test'

@description('The Radius Application Name.')
param applicationName string = 'demo04'

var parameters = contains(environmentName, 'azure') ? {
  location: 'northeurope'
} : {}

@description('The k8s namespace name.')
var kubernetesNamespace = '${environmentName}-${applicationName}'

resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'demo04'
  properties: {
    environment: env.id
    extensions: [
      {
        kind: 'kubernetesNamespace'
        namespace: kubernetesNamespace
      }
      {
        kind: 'kubernetesMetadata'
        labels: {
          'team.name': 'StorageControl'
          'team.costcenter': 'Netherlands'
          'team.contact': 'storage_at_control.com'
          'product.docs': 'readme.md'
        }
      }
    ]
  }
}

resource env 'Applications.Core/environments@2023-10-01-preview' = {
  name: environmentName
  properties: {
    //target kubernetes
    compute: {
      kind: 'kubernetes'
      namespace: environmentName //due to a bug, Radius will append the application name here.
    }
    //register recipes using Bicep
    recipes: {      
      'Applications.Dapr/pubSubBrokers': {
        pubsubRecipe: {
          templateKind: 'bicep'
          templatePath: environmentName == 'test' ? 'acrradius.azurecr.io/recipes/redispubsub:0.1.0' : 'acrradius.azurecr.io/recipes/sbpubsub:0.1.0'
        }
      }

      'Applications.Dapr/stateStores': {
        stateStoreRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/localstatestore:0.1.0'
        }
      }

      'Applications.Core/extenders': {
        jaegerRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/jaeger:0.1.0'
        }
      }    
    }
  }
}

// Zipkin telemetry collection endpoint using 'jaeger_recipe' 
// No resource for OTEL collectors in Radius at this time, so we are using an extender
resource jaegerExtender 'Applications.Core/extenders@2023-10-01-preview' = {
  name: 'jaeger'
  properties: {
    environment: env.id
    application: app.id
    recipe: {
      name: 'jaegerRecipe'
    }
  }
}

// pub/sub messaging using 'sb_pubsub_recipe' 
resource dispatch_pubsub 'Applications.Dapr/pubSubBrokers@2023-10-01-preview' = {
  name: 'dispatchpubsub'
  properties: {
    environment: env.id
    application: app.id
    resourceProvisioning: 'recipe'
    recipe: {
      name: 'pubsubRecipe'
      parameters: parameters
    }
  }
}

output pubsub object = dispatch_pubsub
output jaeger object = jaegerExtender
output environment object = env
output application object = app
