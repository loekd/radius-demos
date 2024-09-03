resource env 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'prod'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: environmentName //Radius will append the application name here.
    }
    providers: providers
    //register recipes using Bicep
    recipes: {      
      'Applications.Dapr/pubSubBrokers': {
        cloudPubsubRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/sbpubsub:0.1.0'
        }
      }

      'Applications.Dapr/stateStores': {
        localStateStoreRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/localstatestore:0.1.2'
        }
        cloudStateStoreRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/cosmosstatestore:0.1.0'
        }
      }

      'Applications.Core/extenders': {
        otlpCollectorRecipe: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/otlp:0.1.0'
        }
      }    
    }
  }
}