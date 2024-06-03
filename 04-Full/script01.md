rad workspace switch local
rad group create test

rad recipe list -e test
rad env show test -o json

rad deploy ./frontend.bicep --parameters hostName=localhost --parameters useHttps=true

#connectivity
kubectl config use-context docker-desktop

wt kubectl port-forward services/frontend 80:80 -n test-demo04
explorer https://localhost

wt kubectl port-forward services/dashboard 7007:80 -n radius-system
explorer http://localhost:7007

wt kubectl port-forward services/jaeger-4jrtpfrsmohwq 16686:16686 -n test-demo04
explorer http://localhost:16686

