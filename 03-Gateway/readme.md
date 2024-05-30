# Into
Assumes you have 2 API containers and 1 Frontend and want to serve them as 1 site, using a reverse proxy.
This is what the Gateway resource is for.

## Bug
Please note that currently the **Gateway doesn't work when running with K3d**. So run this code in Docker Desktop or AKS.
[Issue here](https://github.com/radius-project/radius/issues/7637)

# Run

- `rad init --full`
    - fill out wizard
    - create new environment named 'test'
      - this will create a new Radius resource group called 'test'
    - create a namespace 'test'
    - Do not create an app
    ```
    Initializing Radius. This may take a minute or two...   
                                                            
    ✅ Use existing Radius 0.34.0 install on k3d-k3s-default
    ✅ Create new environment test                          
    - Kubernetes namespace: test                         
    ✅ Update local configuration                           
                                                            
    Initialization complete! Have a RAD time 😎
    ```

- Run the app:
  - `rad run ./app.bicep`

- open a browser
    - navigate to `explorer http://localhost`
    - You should see the standard Nginx welcome page.

- Open a terminal    
    - Call the Blue API:
    - `curl  http://localhost/blue/api/color/`
    - Path rewriting will strip the matched word from the path and forward the request to the downstream (blue) API.

    - Call the Green API:
    - `curl  http://localhost/api/color/`
    - No path rewriting configured, so the path will be forwarded to the downstream (green) API.

    - Call the main site:
    - `curl  http://localhost`
    - No path rewriting configured, so the path will be forwarded to the downstream Nginx.



# Cleanup
- hit `CTRL+C` to stop the port forward, and the app
- `rad app delete demo06 -y`
- `kubectl delete ns test-demo06`

- `rad env delete test -y`
- `rad group delete test -y`