@REM #port forward to app
kubectl config use-context docker-desktop
wt kubectl port-forward services/frontend02 8087:8080 -n test-demo02

@REM #port forward Dapr dashboard
wt kubectl port-forward services/dapr-dashboard 8081:8080 -n dapr-system

@REM #port forward Radius dashboard
wt kubectl port-forward services/dashboard 7007:80 -n radius-system
