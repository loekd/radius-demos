import radius as radius

@description('The Radius Application ID. Injected automatically by the rad CLI.')
param application string

@description('Specifies the environment for resources. Injected automatically by the rad CLI.')
param environment string

resource nginx 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'nginx'
  properties: {
    application: application
    environment: environment
    container: {
      image: 'nginx'      
      ports: {
        web: {
          containerPort: 80
        }
      }
    }
  }
}

resource green 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'green'
  properties: {
    application: application
    environment: environment
    container: {
      image: 'xpiritbv/bluegreen:green'
      env: {
        ASPNETCORE_URLS: 'http://+:8080'
      }
      ports: {
        web: {
          containerPort: 8080
          port: 8080
          protocol: 'TCP'
          scheme: 'http'
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
      env: {
        ASPNETCORE_URLS: 'http://+:8082'
      }
      ports: {
        web: {
          containerPort: 8082
          port: 8082
          protocol: 'TCP'
          scheme: 'http'
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
    internal: true
    hostname: {
      fullyQualifiedHostname: 'localhost'
    }
    routes: [
      {
        path: '/api' 
        destination: 'http://green:8080'
      }      
      {
        path: '/blue'
        destination: 'http://blue:8082'
        replacePrefix: '/'
      }
      {
        path: '/'
        destination: 'http://nginx:80'
      }
    ]
  }
}

