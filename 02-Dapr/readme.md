# Into
Assumes you have an existing Dapr app that has already been containerized. 
You want to run this app using Radius.

# Run

- Run the app:
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
    - `kubectl port-forward services/dashboard 8089:80 -n radius-system`
    - `explorer http://localhost:8089`
    Expose Dapr dashboard (blocking call):
    - `kubectl port-forward services/dapr-dashboard 8088:8080 -n dapr-system`
    - `explorer http://localhost:8088`
    
    
# Observations
- The software doesn't need to know the actual implementation of storage and pub/sub messaging components. (thanks to Dapr and Radius)
- This makes it simpler to define an application with state and messaging elements.

# Cleanup
- hit `CTRL+C` to stop
- `rad app delete demo02 -g test`
- `kubectl delete ns test-demo02`

- `rad recipe unregister default --environment test --resource-type 'Applications.Dapr/stateStores' --group test`
- `rad env delete test -y`
- `rad group delete test -y`