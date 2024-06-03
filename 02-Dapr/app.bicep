import radius as radius

//define explicit radius environment
resource env 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'test'
  properties: {
    //target kubernetes
    compute: {
      kind: 'kubernetes'
      namespace: 'test'
    }
    //register recipe using Bicep
    recipes: {      
      'Applications.Dapr/stateStores': {
        default: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/statestore:0.1.0'
        }
      }    
    }
  }
}

//define explicit radius application
resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'demo02'
  properties: {
    environment: env.id
  }
}

module frontend 'frontend.bicep'= {
  name: 'frontend'
  params: {
    environment: env.id
    application: app.id
  }
  dependsOn: [
    backend
  ]
}

module backend 'backend.bicep'= {
  name: 'backend'
  params: {
    environment: env.id
    application: app.id
  }
}
