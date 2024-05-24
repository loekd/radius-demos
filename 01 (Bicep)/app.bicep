import radius as radius

@description('The Radius Application ID. Injected automatically by the rad CLI.')
param application string

@description('Specifies the environment for resources.')
param environment string

resource container 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'demo'
  properties: {
    // application: app.id
    // environment: env.id
    application: application
    environment: environment
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
// resource env 'Applications.Core/environments@2023-10-01-preview' = {
//   name: 'test'
//   properties:{
//     compute: {
//       kind: 'kubernetes'
//       namespace: 'test-demo01'
//     }
//   }
// }

// resource app 'Applications.Core/applications@2023-10-01-preview' = {
//   name: 'demo01'
//   properties: {
//     environment: env.id
//     extensions: [
//       {
//         kind: 'kubernetesNamespace'
//         namespace: 'test-demo01'
//       } ]
//   }
// }
