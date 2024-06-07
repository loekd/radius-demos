import radius as radius

resource nginx 'Applications.Core/containers@2023-10-01-preview' = {
  name: 'nginx'
  properties: {
    application: app.id
    environment: env.id
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
    application: app.id
    environment: env.id
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
    application: app.id
    environment: env.id
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
    application: app.id
    environment: env.id
    internal: true
    hostname: {
      fullyQualifiedHostname: 'test.loekd.com'
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


//define explicit radius environment
resource env 'Applications.Core/environments@2023-10-01-preview' = {
  name: 'test'
  properties: {
    //target kubernetes
    compute: {
      kind: 'kubernetes'
      namespace: 'test'
    }   
  }
}

//define explicit radius application
resource app 'Applications.Core/applications@2023-10-01-preview' = {
  name: 'demo03'
  properties: {
    environment: env.id
  }
}
