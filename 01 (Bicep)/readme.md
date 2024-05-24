# Into
Assumes you have an existing app that has already been containerized. 
You want to run this app using Radius.

# Run

- `rad init --full`
    - fill out wizard
    - create new environment named 'test'
      - this will create a new Radius resource group called 'test'
    - create a namespace 'test'
    - name the app 'demo01'
- `rad run .\app.bicep -e demos`
- select k8s namespace
    - `kubectl config set-context --current --namespace=test-demo01`
- open a browser
    - navigate to `explorer http://localhost:3000/`

- Forward traffic:
    Expose Radius dashboard (blocking call):
    - `kubectl port-forward services/dashboard 8088:80 -n radius-system`
    - `explorer http://localhost:8088`
# Cleanup
- hit `CTRL+C` to stop
- `rad app remove demo01 -g test`
- `kubectl delete ns test-demo01`

- `rad env delete test -y`
- `rad group delete test -y`