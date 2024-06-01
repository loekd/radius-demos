# Into
Assumes you have an existing app that has already been containerized. 
You want to run this app using Radius.

# Run

- Edit `~/.rad/config.yaml` to make sure there's a workspace called 'dev' and one called 'local'.
  ```yaml
  workspaces:
    default: test
    items:
        dev:
            connection:
                context: k3d-k3s-default
                kind: kubernetes
            environment: /planes/radius/local/resourceGroups/dev/providers/Applications.Core/environments/dev
            scope: /planes/radius/local/resourceGroups/dev
        local:
            connection:
                context: k3d-k3s-default
                kind: kubernetes
            environment: /planes/radius/local/resourceGroups/test/providers/Applications.Core/environments/test
            scope: /planes/radius/local/resourceGroups/test
  ```


- Switch to the dev workspace:
  `rad workspace switch dev`

- Create a new resource group
  - `rad group create dev`
    
- Run the app:
  - `rad run ./app.bicep -g dev --application demo00`

- open a browser
    - navigate to `explorer http://localhost:3000/`

- Explore the Radius dashboard:
    - `explorer http://localhost:7007`
    - Examine the registered recipes for environment 'dev'.

# Cleanup
- hit `CTRL+C` to stop the port forward, and the app
- `rad app delete demo00 -g dev -y`
- `kubectl delete ns dev-demo00`

- `rad env delete dev -y`
- `rad group delete dev -y`