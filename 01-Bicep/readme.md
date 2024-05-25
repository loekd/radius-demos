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
    ```
    Initializing Radius. This may take a minute or two...   
                                                            
    ✅ Use existing Radius 0.34.0 install on k3d-k3s-default
    ✅ Create new environment test                          
    - Kubernetes namespace: test                         
    ✅ Update local configuration                           
                                                            
    Initialization complete! Have a RAD time 😎
    ```

- Run the app:
  - `rad run ./app.bicep -e test`

- open a browser
    - navigate to `explorer http://localhost:3000/`

- Forward traffic:
    In a new terminal, expose Radius dashboard (blocking call):
    - `kubectl port-forward services/dashboard 8088:80 -n radius-system`

- Explore the Radius dashboard:
    - `explorer http://localhost:8088`

# Cleanup
- hit `CTRL+C` to stop the port forward, and the app
- `rad app delete demo01 -g test -y`
- `kubectl delete ns test-demo01`

- `rad env delete test -y`
- `rad group delete test -y`