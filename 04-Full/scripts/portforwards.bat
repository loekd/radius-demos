@REM #port forward to app
kubectl config use-context docker-desktop
wt kubectl port-forward services/frontend 80:80 -n test-demo04

@REM #port forward Jaeger
wt kubectl port-forward services/jaeger-4jrtpfrsmohwq 16686:16686 -n test-demo04

@REM #port forward Radius dashboard
wt kubectl port-forward services/dashboard 7007:80 -n radius-system







