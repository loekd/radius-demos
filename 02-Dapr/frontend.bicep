extension radius

@description('Specifies the environment for resources.')
param environment string

@description('The ID of your Radius Application. Automatically injected by the rad CLI.')
param application string

// The frontend container that serves the application UI
resource frontend02 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'frontend02'
  properties: {
    application: application
    environment: environment
    container: {
      // This image is where the app's frontend code lives
      image: 'ghcr.io/radius-project/samples/dapr-frontend:latest'
      env: {
        CONNECTION_BACKEND_APPID: {
        value: 'backend'
        }
        ASPNETCORE_URLS: {
          value: 'http://*:8080'
        }
      }
      // The frontend container exposes port 8080, which is used to serve the UI
      ports: {
        ui: {
          containerPort: 8080
        }
      }
    }
    // The extension to configure Dapr on the container, which is used to invoke the backend
    extensions: [
      {
        kind: 'daprSidecar'
        appId: 'frontend'
      }
    ]
  }
}
