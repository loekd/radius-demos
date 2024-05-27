import radius as radius

@description('The Radius Application ID. Injected automatically by the rad CLI.')
param application string

@description('Specifies the environment for resources. Injected automatically by the rad CLI.')
param environment string

resource green 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'green'
  properties: {
    application: application
    environment: environment
    container: {
      image: 'xpiritbv/bluegreen:green'
      ports: {
        web: {
          containerPort: 8080
        }
      }
    }
  }
}

resource blue 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'blue'
  properties: {
    application: application
    environment: environment
    container: {
      image: 'xpiritbv/bluegreen:blue'
      ports: {
        web: {
          containerPort: 8080
        }
      }
    }
  }
}


resource gateway 'Applications.Core/gateways@2023-10-01-preview' = {
  name: 'buggy-gateway'
  properties: {
    application: application 
    environment: environment
    hostname: {
      fullyQualifiedHostname: 'localhost'
    }
    routes: [
      {
        path: '/blue'
        destination: 'http://${blue.name}:${blue.properties.container.ports.web.containerPort}'
        replacePrefix: '/blue'  
      }      
      {
        path: '/green' 
        destination: 'http://${green.name}:${green.properties.container.ports.web.containerPort}'
        replacePrefix: '/green'
      }      
    ]
  }
}

