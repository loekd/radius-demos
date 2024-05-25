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
- Publish and Register the custom state store recipe:
  - `rad bicep publish --file stateStoreRecipe.bicep --target br:acrradius.azurecr.io/recipes/statestore:0.1.0`
  - `rad recipe register default --environment test --resource-type 'Applications.Dapr/stateStores' --template-kind bicep --template-path acrradius.azurecr.io/recipes/statestore:0.1.0 --group test`
- Select k8s namespace
    - `kubectl config set-context --current --namespace=test-demo04`
- Open a browser
    - navigate to the backend API, `explorer http://localhost:3000/order`
    - show the frontend: `explorer http://localhost:8080`

- Forward traffic:
    Expose Radius dashboard (blocking call):
    - `kubectl port-forward services/dashboard 8088:80 -n radius-system`
    - `explorer http://localhost:8088`
    
# Cleanup
- hit `CTRL+C` to stop
- `rad app delete demo04 -g test`
- `kubectl delete ns test-demo04`

- `rad env delete test -y`
- `rad group delete test -y`