# Into
Assumes you have an existing app that has already been containerized and deployed. 
You want to show this app on the Radius dashboard.

# Run
- Check existing recipes:
  - `rad recipe list -g demos -e demos`
- Publish the customized Redis Cache recipe to an OCI registry:
  - `rad bicep publish --file redisCacheRecipe.bicep --target br:acrradius.azurecr.io/recipes/rediscache:0.1.0`
- Register the recipe as part of the environment:
  - `rad recipe register default --environment demos --resource-type 'Applications.Datastores/redisCaches' --template-kind bicep --template-path acrradius.azurecr.io/recipes/rediscache:0.1.0 --group demos`
- Check existing recipes again:
  - `rad recipe list -g demos -e demos`

- Create and select k8s namespace
    - `kubectl create ns demos-demo02`
    - `kubectl config set-context --current --namespace=demos-demo02`
- Deploy the app using kubectl (not Radius)
    - `kubectl apply -f .\deployment.yaml`
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
  radapp.io/environment: demos
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
      environment: 'demos'
      type: Applications.Datastores/redisCaches
  ```
- Redeploy and open the Radius Dashboard. It does show the app and the cache.
  - `explorer http://localhost:8088`

# Cleanup
- Hit `CTRL+C` to stop port forward
- Cleanup:
  - `kubectl delete -f .\deployment.yaml`
  - `kubectl delete ns demos-demo02`