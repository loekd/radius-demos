import radius as radius

@description('The Radius Application ID. Injected automatically by the rad CLI.')
param application string

@description('Specifies the environment for resources. Injected automatically by the rad CLI.')
param environment string

resource container 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'demo'
  properties: {
    application: application //Use the injected application ID
    environment: environment //Use the injected environment ID
    container: {
      image: 'ghcr.io/radius-project/samples/demo:latest'
      ports: {
        web: {
          containerPort: 3000
        }
      }
    }
    // Uncomment the following code to connect to the Redis cache below
    // connections:{
    //   orders: {
    //     source: redisCache.id
    //   }
    // }
  }
}

//uncomment the following code to add a Redis cache
// resource redisCache 'Applications.Datastores/redisCaches@2023-10-01-preview' = {
//   name: 'redis'
//   properties: {
//     application: application
//     environment: environment
//     recipe: {
//       name: 'default'
//     }
//   }
// }
