// Shared services like Zipkin and Pub/Sub are defined here. Used from Dispatch and Plant APIs.

import radius as radius

@description('Specifies the Environment Name.')
param environmentName string = 'test'

@description('The Radius Application Name.')
param applicationName string = 'demo04'

var providers = environmentName == 'prod' ? {
  azure: {
    scope: '/subscriptions/6eb94a2c-34ac-45db-911f-c21438b4939c/resourceGroups/rg-radius'
  }
} : {}

var parameters = contains(environmentName, 'azure') ? {
  location: 'northeurope'
} : {}

@description('The k8s namespace name.')
var kubernetesNamespace = '${environmentName}-${applicationName}'

var pubSubRecipeName = environmentName == 'prod' ? 'cloudPubsubRecipe' : 'localPubsubRecipe'
var stateStoreRecipeName = environmentName == 'prod' ? 'cloudStateStoreRecipe' : 'localStateStoreRecipe'


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
    //target azure in prod
    providers: providers
    //register recipes using Bicep
    recipes: {      
      'Applications.Dapr/pubSubBrokers': {
        localPubsubRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/redispubsub:0.1.0'
        }
        cloudPubsubRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/sbpubsub:0.1.0'
        }
      }

      'Applications.Dapr/stateStores': {
        localStateStoreRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/localstatestore:0.1.0'
        }
        cloudStateStoreRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/cosmosstatestore:0.1.0'
        }
      }

      'Applications.Core/extenders': {
        jaegerRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/jaeger:0.1.0'
        }
        //TODO: OTEL collector recipe for cloud
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
      name: environmentName == 'prod' ? 'cloudPubsubRecipe' : 'localPubsubRecipe'      
      parameters: parameters
    }
  }
}

output pubsub object = dispatch_pubsub
output jaeger object = jaegerExtender
output environment object = env
output application object = app
output stateStoreRecipeName string = stateStoreRecipeName
output pubSubRecipeName string = pubSubRecipeName
