extension radius

//define radius environment
resource env 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'test'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'test'
    }
    recipes: {
      //register recipe using Bicep
      'Applications.Datastores/redisCaches': {
        default: {
          templateKind: 'bicep'
          templatePath: 'acrradius.azurecr.io/recipes/rediscache:0.1.0'
        }
      }
    }
  }
}

//define radius application
resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'demo01'
  properties: {
    environment: env.id
  }
}

//define container that runs the application
resource container01 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'container01'
  properties: {
    application: app.id
    environment: env.id
    container: {
      image: 'ghcr.io/radius-project/samples/demo:latest'
      imagePullPolicy: 'IfNotPresent'
      ports: {
        web: {
          containerPort: 3000
        }
      }
    }
    connections: {
      redis: {
        source: redisCache01.id
      }
    }
  }
}

// add a Redis cache using a recipe
resource redisCache01 'Applications.Datastores/redisCaches@2023-10-01-preview' = {
  name: 'redis01'
  properties: {
    application: app.id
    environment: env.id
    recipe: {
      name: 'default'
    }
  }
}
