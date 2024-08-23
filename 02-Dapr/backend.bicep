extension radius

@description('Specifies the environment for resources.')
param environment string

@description('The ID of your Radius Application. Automatically injected by the rad CLI.')
param application string

// The backend container that is connected to the Dapr state store
resource backend02 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'backend02'
  properties: {
    application: application
    container: {
      // This image is where the app's backend code lives
      image: 'ghcr.io/radius-project/samples/dapr-backend:latest'
      ports: {
        orders: {
          containerPort: 3000
        }
      }
    }
    //connection provides component name, not connection string
    connections: {
      orders: {
        source: stateStore02.id
      }
    }
    extensions: [
      {
        kind: 'daprSidecar'
        appId: 'backend'
        appPort: 3000
      }
    ]
  }
}

// The Dapr state store that is connected to the backend container
resource stateStore02 'Applications.Dapr/stateStores@2023-10-01-preview' = {
  name: 'statestore02'
  properties: {
    // Provision Redis Dapr state store automatically via Radius Recipe
    environment: environment
    application: application
    resourceProvisioning: 'recipe'
    recipe: {     
      name: 'default'
    }
  }
}

// Or provision Cosmos DB as Dapr state store, assuming rad init --full was configured with cloud details.
// Or run 'rad credential register azure' and 'rad env update --azure-subscription-id <subscription-id> --azure-resource-group <azure rg>' to configure Azure.

// resource stateStore02 'Applications.Dapr/stateStores@2023-10-01-preview' = {
//   name: 'cos-ordersdemo02'
//   properties: {
//     environment: environment
//     application: application
//     // Provision Redis Dapr state store as Cosmos DB in Azure
//     resourceProvisioning: 'recipe'
//     recipe: {     
//       name: 'cloudStateStoreRecipe'
//       parameters: {
//         databaseName: 'orders'
//         appId: 'backend02'
//       }
//     }
//   }
// }
