# Into
Assumes you have an existing app that has already been containerized and deployed. 
You want to show this app on the Radius dashboard.

# Run
- Create a place to store custom recipe:
  - `rad init --full`
    - fill out wizard
    - create new environment named 'test'
      - this will create a new Radius resource group called 'test'
    - create a namespace 'test'
    - don't create an app
- Check existing recipes:
  - `rad recipe list -g test -e test`
- Publish the customized Redis Cache recipe to an OCI registry:
  - `rad bicep publish --file redisCacheRecipe.bicep --target br:acrradius.azurecr.io/recipes/rediscache:0.1.0`
- Register the recipe as part of the environment:
  - `rad recipe register default --environment test --resource-type 'Applications.Datastores/redisCaches' --template-kind bicep --template-path acrradius.azurecr.io/recipes/rediscache:0.1.0 --group test`
- Check existing recipes again:
  - `rad recipe list -g test -e test`

- Create and select k8s namespace
    - `kubectl create ns test-demo02`
    - `kubectl config set-context --current --namespace=test-demo02`
- Deploy the app using kubectl (not Radius)
    - `kubectl apply -f .\deployment.yaml --namespace test-demo02`
- Forward traffic
    Forward traffic to the demo app (blocking call):
    - `kubectl port-forward services/demo 3000:3000`
    Expose Radius dashboard (blocking call):
    - `kubectl port-forward services/dashboard 8088:80 -n radius-system`
    
- Open a browser and show the app:
    - `explorer http://localhost:3000`
- Explore the Radius Dashboard, it does not show the app.
  - `explorer http://localhost:8088`

## Enable Radius
- Enable Radius: 
  - Open 'deployment.yaml' and enable lines 7 & 8:
  ```yaml
  radapp.io/enabled: 'true'
  radapp.io/environment: test
  ```
- Redeploy and open the Radius Dashboard. It does show the app
  - `explorer http://localhost:8088`

## Use Radius Connections

- Deploy Redis Cache container: 
  - Open 'deployment.yaml' and enable lines 10 and 76-82:
  ```yaml
  radapp.io/connection-redis: 'db'
  ...
  ...
  ...
  apiVersion: radapp.io/v1alpha3
    kind: Recipe
    metadata:
      name: db
    spec:
      environment: 'test'
      type: Applications.Datastores/redisCaches
  ```
- Redeploy and open the Radius Dashboard. It does show the app and the cache.
  - `explorer http://localhost:8088`

# Cleanup
- Hit `CTRL+C` to stop port forward
- Cleanup:
  - `rad app delete test-demo02 -g test-test-demo02`
  - `kubectl delete -f .\deployment.yaml`
  - `kubectl delete ns test-demo02`