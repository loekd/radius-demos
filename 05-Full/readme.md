# Getting started

## Certs
- Use CertBot to get a certificate:
  - `docker run -it certbot/certbot certonly --manual --preferred-challenges dns -d demo.loekd.com`

# Local runs

## Prepare

- `rad init --full`
    - fill out wizard
    - create new environment named 'test'
      - this will create a new Radius resource group called 'test'
    - create a namespace 'test'
    - Do not scaffold an app.

     ```
     You've selected the following:

        🔧 Use existing Radius 0.33.0 install on docker-desktop
        🌏 Create new environment test
        - Kubernetes namespace: test
        - Create app.bicep
        - Create .rad\rad.yaml
        📋 Update local configuration

        (press enter to confirm or esc to restart)
     ```


- Deploy **local** recipes
    - `cd local`
    - `rad recipe register pubsubRecipe --environment test --resource-type 'Applications.Dapr/pubSubBrokers' --template-kind bicep --template-path acrradius.azurecr.io/recipes/redispubsub:0.1.0 --group test`
    - `rad recipe register stateStoreRecipe --environment test --resource-type 'Applications.Dapr/stateStores' --template-kind bicep --template-path acrradius.azurecr.io/recipes/localstatestore:0.1.0 --group test`
    - `rad recipe register jaegerRecipe --environment test --resource-type 'Applications.Core/extenders' --template-kind bicep --template-path acrradius.azurecr.io/recipes/jaeger:0.1.0 --group test`
    - `cd ..`
## Run

- Set kubectl context if needed:
    - `kubectl config use-context docker-desktop`    
- Deploy the Plant API:
    - `rad deploy ./plant.bicep`
- Deploy the Dispatch api:
    - `rad deploy ./dispatch.bicep`
    - If you get `"message": "Container state is 'Terminated' Reason: Error, Message: "` errors, try run & deploy again until it works
- Run the Frontend and Gateway:
    - Codespaces:
        - `rad run ./frontend.bicep --parameters hostName=$CODESPACE_NAME-8080.app.github.dev`
        - Turn dispatch port to public (to allow CORS)
            `gh codespace ports visibility 8080:public -c $CODESPACE_NAME`
    - Localhost:        
        - `rad run ./frontend.bicep --parameters hostName=localhost` (access trough gateway)
    - Please note that the Gateway breaks signalR after 15s
        - fix: `kubectl patch httpproxy dispatchapi -n test-demo05 --type='json' -p='[{"op": "add", "path": "/spec/routes/0/enableWebsockets", "value": true}]'`
        - This can block redeployments, so delete the custom resource if you see any errors about 'patch httpproxy':
        - `kubectl delete httpproxy dispatchapi -n test-demo05`

# Azure

## Prepare
- Connect a DNS Entry to the kubernetes IP address of your AKS Cluster
- Optionally link it as a CName to your own domain.
- Get a TLS certificate
- Or comment out ln 158-165 from 'frontend.bicep'.
  ```yaml
  data: {
      'tls.key': {
        value: loadTextContent('privkey.pem')
      }
      'tls.crt': {
        value: loadTextContent('fullchain.pem')
      }
    }
  ```

- Create a new workspace for Azure
    - `rad workspace create kubernetes prod --context aksradius`

- Get credentials for an AKS cluster
    - `az aks get-credentials -g rg-radius -n aksradius` (replace with your details)

- Create an SPN with Owner access on Azure Resource Group
    - Create a Client Secret
    - Capture Client ID
    - Capture Tenant ID

- Create a radius environment: `rad init --full`
    - Use the AKS context
    - Use 'prod' as environment and namespace.
    - Configure it for Azure, with the SPN details
    - Do not scaffold / setup an application
    
- Register the recipes
    - `cd azure`
    - Service Bus (replaces Redis Pub/Sub with Cloud PaaS) 
        - `rad bicep publish --file sb_pubsub_recipe.bicep --target br:acrradius.azurecr.io/recipes/sbpubsub:0.1.0`
        - `rad recipe register pubsubRecipe --environment prod --resource-type 'Applications.Dapr/pubSubBrokers' --template-kind bicep --template-path acrradius.azurecr.io/recipes/sbpubsub:0.1.0`
    - Local MongoDb (because Cosmos doesn't support query Dapr API)
        - `rad bicep publish --file local_statestore_recipe.bicep --target br:acrradius.azurecr.io/recipes/localstatestore:0.1.0`
        - `rad recipe register stateStoreRecipe --environment prod --resource-type 'Applications.Dapr/stateStores' --template-kind bicep --template-path acrradius.azurecr.io/recipes/localstatestore:0.1.0`
    - Local Jaeger (can be replaced with OTEL forwarder)
        - `rad bicep publish --file jaeger_recipe.bicep --target br:acrradius.azurecr.io/recipes/jaeger:0.1.0`
        - `rad recipe register jaegerRecipe --environment prod --resource-type 'Applications.Core/extenders' --template-kind bicep --template-path acrradius.azurecr.io/recipes/jaeger:0.1.0`
    - `cd ..`

## Run

- Deploy plant API
    - `kubectl config use-context aksradius` (if needed)
    - `rad workspace switch prod` (if needed)
    - `rad deploy ./plant.bicep`
- Deploy dispatch api
    - `rad deploy ./dispatch.bicep`

- Run frontend:        
    - Public AKS IP Address:        
        - `rad run ./frontend.bicep --parameters hostName=demo.loekd.com` (access trough gateway)     
    - Please note that the Gateway currently breaks signalR after 15s
        - fix: `kubectl patch httpproxy dispatchapi -n prod-demo05 --type='json' -p='[{"op": "add", "path": "/spec/routes/0/enableWebsockets", "value": true}]'`
        - This can block redeployments, so delete the custom resource if you see any errors about 'patch httpproxy':
        - `kubectl delete httpproxy dispatchapi -n prod-demo05`

## Usage

Open the user interface.
- `https://demo.loekd.com`
- Log in using Azure AD B2C
- Inject some gas 
- When everything is working, you will get a notification about processing, and the numbers should increase or decrease.

Check Gas In Store at Plant level:
- Browse:
    `https://demo.loekd.com/api/gasinstore/gasinstore`
- Adjust:
    - Port forward to plant api
    - `curl -v -X POST http://localhost:8082/api/gasinstore/20`


## Developer tools

### Redis
- Create a Port Forward to Redis. (change the pod name to the actual value)
    - `kubectl port-forward pods/daprpubsub-fd6yvbjatqj5a-577df9c456-cbfbb 6379:6379 -n default-radius`
- Use the VS Code extension to connect to it on `localhost`, without credentials.


## MongoDb
- Create a Port Forward to MongoDb in `default` namespace
    - `kubectl port-forward pods/mongo-mongodb-0 27017:27017 -n default`
- Connect using extension: `mongodb://localhost:27017/?directConnection=true&replicaSet=rs0`

## Debugging
- Run busybox inside a new terminal, to run an interactive container inside K8s for debugging:
    - `kubectl run bb --image=busybox -i --tty --restart=Never -n default` 