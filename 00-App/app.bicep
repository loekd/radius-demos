extension radius

//define explicit radius environment
resource env 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'dev'
  properties: {
    //target kubernetes
    compute: {
      kind: 'kubernetes'
      namespace: 'dev'
    }
    //register recipe using Bicep
    recipes: {      
      'Applications.Datastores/redisCaches': {
        default: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/rediscache:0.1.0'
        }
      }
    
    }
  }
}

//define explicit radius application
resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'demo00'
  properties: {
    environment: env.id
  }
}

//run a container as part of the environment and application
resource container 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'demo'
  properties: {
    application: app.id
    environment: env.id
    container: {
      image: 'ghcr.io/radius-project/samples/demo:latest'
      ports: {
        web: {
          containerPort: 3000
        }
      }
    }
  }
}

