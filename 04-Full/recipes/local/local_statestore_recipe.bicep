// MongoDb running as mongod replicaset on 1 k8s replica
// Can be used for Dapr state stores with query support and actor state stores.
// ReplicaSet is disabled by default. To enable it, set the replicaset parameter to true. 
// Use 'rs0' as the replica set name. (e.g. params: '?replicaSet=rs0' in the component metadata)
// Credentials are currently ignored. 

@description('Information about what resource is calling this Recipe. Generated by Radius. For more information visit https://docs.radapp.dev/operations/custom-recipes/')
param context object

@description('The name of the database. Defaults to an empty string.')
param databaseName string = ''

@description('Admin username for the Mongo database. Default is "admin"')
param username string = 'admin'

@description('Admin password for the Mongo database')
@secure()
#disable-next-line secure-parameter-default
param password string = 'Password1234=='

@description('Create a Mongo Replicaset? Default is false')
param replicaset bool = false

@description('The appId to scope to')
param appId string

extension radius
extension kubernetes with {
  kubeConfig: ''
  namespace: context.runtime.kubernetes.namespace
} as kubernetes

var daprType = 'state.mongodb'
var daprVersion = 'v1'
var host = '${svc.metadata.name}.${svc.metadata.namespace}.svc.cluster.local:${port}'
var uniqueName = 'mongo-${uniqueString(context.resource.id)}'
var port = 27017

var env = replicaset ? [
  {
    name: 'MONGO_INITDB_ROOT_USERNAME'
    value: username
  }
  {
    name: 'MONGO_INITDB_ROOT_PASSWORD'
    value: password
  }
  {
    name: 'MONGODB_REPLICA_SET_MODE'
    value: 'primary'
  }
] : [
  {
    name: 'MONGO_INITDB_ROOT_USERNAME'
    value: username
  }
  {
    name: 'MONGO_INITDB_ROOT_PASSWORD'
    value: password
  }
]

var volumes = [
  {
    name: 'scripts'
    configMap: {
      name: '${databaseName}-mongodb-scripts'
    }
  }
]

var volumeMounts = [
  {
    name: 'scripts'
    mountPath: '/scripts/setup.sh'
    subPath: 'setup.sh'
  }
  {
    name: 'scripts'
    mountPath: '/scripts/ping-mongodb.sh'
    subPath: 'ping-mongodb.sh'
  }
]

var readinessProbe = {
  exec: {
    command: [
      'sh', '/scripts/ping-mongodb.sh'
    ]
  }
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 5
  failureThreshold: 10
  successThreshold: 1
}

var livenessProbe = {
  exec: {
    command: replicaset ? [
      'sh', '/scripts/setup.sh'
    ] : [
      'sh', '/scripts/ping-mongodb.sh'
    ]
  }
  initialDelaySeconds: 5
  periodSeconds: 10
  timeoutSeconds: 10
  failureThreshold: 30
  successThreshold: 1
}

var startupProbe = {
  exec: {
    command: [
      'sh', '/scripts/ping-mongodb.sh'
    ]
  }
  initialDelaySeconds: 30
  periodSeconds: 10
  timeoutSeconds: 10
  failureThreshold: 30
  successThreshold: 1
}

var command = replicaset ? [ 'mongod', '--replSet', 'rs0', '--bind_ip_all', '--port', '27017' ] : [ 'mongod', '--bind_ip_all', '--port', '27017' ]

resource configMap 'core/ConfigMap@v1' = {
  metadata: {
    name: '${databaseName}-mongodb-scripts'
  }
  data: {
    'setup.sh': 'echo "try { rs.status() } catch (err) { rs.initiate({_id:\'rs0\',members:[{_id:0,host:\'${host}\'}]}) }" | mongosh --port 27017 --quiet'
    'ping-mongodb.sh': 'exec mongosh --port 27017 --eval "db.adminCommand(\'ping\')"'
  }
}

resource mongo 'apps/Deployment@v1' = {
  metadata: {
    name: uniqueName
  }
  spec: {
    selector: {
      matchLabels: {
        app: 'mongo'
        resource: context.resource.name
      }
    }
    template: {
      metadata: {
        labels: {
          app: 'mongo'
          resource: context.resource.name
          // Label pods with the application name so `rad run` can find the logs.
          // NOTE: disabled because rad run only lets you see logs from 10 pods
          //'radapp.io/application': context.application == null ? '' : context.application.name
        }
      }
      spec: {
        containers: [
          {
            name: 'mongo'
            image: 'mongo:6.0'
            ports: [
              {
                containerPort: port
              }
            ]
            env: env
            volumeMounts: volumeMounts
            readinessProbe: readinessProbe
            livenessProbe: livenessProbe
            startupProbe: startupProbe
            command: command
          }
        ]
        volumes: volumes
      }
    }
  }
}

resource svc 'core/Service@v1' = {
  metadata: {
    name: uniqueName
    labels: {
      name: uniqueName
    }
  }
  spec: {
    type: 'ClusterIP'
    selector: {
      app: 'mongo'
      resource: context.resource.name
    }
    ports: [
      {
        port: port
      }
    ]
  }
}

resource daprComponent 'dapr.io/Component@v1alpha1' = {
  metadata: {
    name: context.resource.name
  }
  scopes: [
    appId
  ]
  spec: {
    metadata: [
      {
        name: 'host'
        value: '${svc.metadata.name}.${svc.metadata.namespace}.svc.cluster.local'
      }, {
        name: 'databaseName'
        value: databaseName
      }, {
        name: 'collectionName'
        value: context.resource.name
      }, {
        name: 'username'
        value: null
      }, {
        name: 'password'
        value: null
      }, {
        name: 'operationTimeout'
        value: '30s'
      }, {
        name: 'params'
        value: replicaset ? '?replicaSet=rs0' : ''
      }
    ]
    type: daprType
    version: daprVersion
  }
}

output result object = {
  // This workaround is needed because the deployment engine omits Kubernetes resources from its output.
  //
  // Once this gap is addressed, users won't need to do this.
  resources: [
    '/planes/kubernetes/local/namespaces/${svc.metadata.namespace}/providers/core/Service/${svc.metadata.name}'
    '/planes/kubernetes/local/namespaces/${mongo.metadata.namespace}/providers/apps/Deployment/${mongo.metadata.name}'
    '/planes/kubernetes/local/namespaces/${daprComponent.metadata.namespace}/providers/dapr.io/Component/${daprComponent.metadata.name}'
  ]
  values: {
    host: '${svc.metadata.name}.${svc.metadata.namespace}.svc.cluster.local'
    port: port
    username: username
    database: databaseName
    replicaset: replicaset
    type: daprType
    version: daprVersion
    metadata: daprComponent.spec.metadata
    
  }
  secrets: {
    // Temporarily workaround until secure outputs are added
    #disable-next-line outputs-should-not-contain-secrets
    connectionString: 'mongodb://${username}:${password}@${svc.metadata.name}.${svc.metadata.namespace}.svc.cluster.local:${port}'
    #disable-next-line outputs-should-not-contain-secrets
    password: password
  }
}

//deploying the recipe can be done by this command:
//rad bicep publish --file local_statestore_recipe.bicep --target br:acrradius.azurecr.io/recipes/localstatestore:0.1.1

//rad recipe register stateStoreRecipe --environment prod --resource-type 'Applications.Dapr/stateStores' --template-kind bicep --template-path acrradius.azurecr.io/recipes/localstatestore:0.1.1 --group prod
//rad recipe register stateStoreRecipe --environment test --resource-type 'Applications.Dapr/stateStores' --template-kind bicep --template-path acrradius.azurecr.io/recipes/localstatestore:0.1.1 --group test
