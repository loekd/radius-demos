extension radius

//define radius environment
resource env 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'test'
  properties: {
    compute: {
      kind: 'kubernetes'
      namespace: 'test'
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
  }
}
