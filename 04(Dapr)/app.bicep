@description('Specifies the environment for resources.')
param environment string

@description('The ID of your Radius Application. Automatically injected by the rad CLI.')
param application string

module frontend 'frontend.bicep'= {
  name: 'frontend'
  params: {
    environment: environment
    application: application
  }
  dependsOn: [
    backend
  ]
}

module backend 'backend.bicep'= {
  name: 'backend'
  params: {
    environment: environment
    application: application
  }
}
