rad workspace switch local
rad group create test
rad deploy ./app.bicep --group test

#port forward to app
kubectl config use-context docker-desktop
wt kubectl port-forward services/frontend02 8087:8080 -n test-demo02
explorer http://localhost:8087/

#port forward Dapr dashboard
wt kubectl port-forward services/dapr-dashboard 8081:8080 -n dapr-system
explorer http://localhost:8081/

#port forward Radius dashboard
wt kubectl port-forward services/dashboard 7007:80 -n radius-system
explorer http://localhost:7007

#clean app
rad app delete demo02 -y
#kill port forwards!