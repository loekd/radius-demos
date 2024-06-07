/*
Copyright 2023 The Radius Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

@description('Information about what resource is calling this Recipe. Generated by Radius. For more information visit https://docs.radapp.dev/operations/custom-recipes/')
param context object

import kubernetes as kubernetes {
  kubeConfig: ''
  namespace: context.runtime.kubernetes.namespace
}
//kubernetes deployment for Redis cache
resource redis 'apps/Deployment@v1' = {
  metadata: {
    name: 'redis-${uniqueString(context.resource.id)}'
  }
  spec: {
    selector: {
      matchLabels: {
        app: 'redis'
        resource: context.resource.name
      }
    }
    template: {
      metadata: {
        labels: {
          app: 'redis'
          resource: context.resource.name

          // Label pods with the application name so `rad run` can find the logs.
          'radapp.io/application': context.application == null ? '' : context.application.name
        }
      }
      spec: {
        containers: [
          {
            // This container is the running redis instance.
            name: 'redis'
            image: 'redis'
            imagePullPolicy: 'IfNotPresent'
            ports: [
              {
                containerPort: 6379
              }
            ]
          }
          {
            // This container will connect to redis and stream logs to stdout for aid in development.
            name: 'redis-monitor'
            image: 'redis'
            args: [
              'redis-cli'
              '-h'
              'localhost'
              'MONITOR'
            ]
          }
        ]
      }
    }
  }
}
//kubernetes service for cache connectivity
resource svc 'core/Service@v1' = {
  metadata: {
    name: 'redis-${uniqueString(context.resource.id)}'
  }
  spec: {
    type: 'ClusterIP'
    selector: {
      app: 'redis'
      resource: context.resource.name
    }
    ports: [
      {
        port: 6379
      }
    ]
  }
}
//required return values for Radius (connection)
output result object = {
  resources: [
    '/planes/kubernetes/local/namespaces/${svc.metadata.namespace}/providers/core/Service/${svc.metadata.name}'
    '/planes/kubernetes/local/namespaces/${redis.metadata.namespace}/providers/apps/Deployment/${redis.metadata.name}'
  ]
  values: {
    host: '${svc.metadata.name}.${svc.metadata.namespace}.svc.cluster.local'
    port: 6379
  }
}

//publish the recipe to an OCI registry:
//rad bicep publish --file redisCacheRecipe.bicep --target br:acrradius.azurecr.io/recipes/rediscache:0.1.0

//don't register the recipe as part of the environment:
//rad recipe register default --environment dev --resource-type 'Applications.Datastores/redisCaches' --template-kind bicep --template-path acrradius.azurecr.io/recipes/rediscache:0.1.0 --group dev


