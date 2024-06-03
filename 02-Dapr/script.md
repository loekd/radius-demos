rad workspace switch local
rad group create test
rad deploy ./app.bicep --group test

#port forward to app
wt kubectl port-forward services/frontend02 8087:8080 -n test-demo02
explorer http://localhost:8087/

#port forward Dapr dashboard
wt kubectl port-forward services/dapr-dashboard 8088:8080 -n dapr-system
explorer http://localhost:8088/

#port forward Radius dashboard
wt kubectl port-forward services/dashboard 8089:80 -n radius-system
explorer http://localhost:8089

#clean app
rad app delete demo02 -y
#kill port forwards!