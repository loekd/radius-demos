# Into
Assumes you have an existing Dapr app that has already been containerized. 
You want to run this app using Radius.

# Run

- `rad init --full`
    - fill out wizard
    - create new environment named 'test'
      - this will create a new Radius resource group called 'test'
    - create a namespace 'test'
    - name the app 'demo04'

     ```
     You've selected the following:

        🔧 Use existing Radius 0.33.0 install on docker-desktop
        🌏 Create new environment test
        - Kubernetes namespace: test
        🚧 Scaffold application demo04
        - Create app.bicep
        - Create .rad\rad.yaml
        📋 Update local configuration

        (press enter to confirm or esc to restart)
     ```

- `rad run ./app.bicep -e test`
  - If it returns a timeout error, just try again.
  - It should report an issue about a missing recipe.
- Publish and Register the custom state store recipe:
  - `rad bicep publish --file stateStoreRecipe.bicep --target br:acrradius.azurecr.io/recipes/statestore:0.1.0` (skip if you don't have an ACR)
  - `rad recipe register default --environment test --resource-type 'Applications.Dapr/stateStores' --template-kind bicep --template-path acrradius.azurecr.io/recipes/statestore:0.1.0 --group test`

- Run the app again:
  - `rad run ./app.bicep -e test`
  - If it returns a timeout error, just try again.
  
- Select k8s namespace
    - `kubectl config set-context --current --namespace=test-demo04`
- Open a browser
    - navigate to the backend API, `explorer http://localhost:3000/order`
    - show the frontend: `explorer http://localhost:8080`
    - The frontend is talking to the backend, connection provided by Dapr.
    - The backend uses a database, connection details provided by Radius.

- Forward traffic:
    Expose Radius dashboard (blocking call):
    - `kubectl port-forward services/dashboard 8088:80 -n radius-system`
    - `explorer http://localhost:8088`
    
# Observations
- The software doesn't need to know the actual implementation of storage and pub/sub messaging components. (thanks to Dapr)
- This makes it simpler to define an application with state and messaging elements.

# Cleanup
- hit `CTRL+C` to stop
- `rad app delete demo02 -g test`
- `kubectl delete ns test-demo02`

- `rad env delete test -y`
- `rad group delete test -y`