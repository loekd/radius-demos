@REM #set correct k8s cluster
kubectl config use-context docker-desktop

@REM #port forward Jaeger
wt kubectl port-forward services/jaeger-3cat3stttmlle 16686:16686 -n test-demo04

@REM #port forward Radius dashboard
wt kubectl port-forward services/dashboard 7007:80 -n radius-system







