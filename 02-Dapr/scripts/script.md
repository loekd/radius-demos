clear
cd /Users/loekd/projects/radius-demos/02-Dapr
rad deploy ./app.bicep --group ateam --environment test

#rad application graph demo02

#run port forward to frontend using rad:
rad resource expose --group ateam --application demo02 Applications.Core/containers frontend02 --port 8087 --remote-port 8080 &
$RETURN

#run port forwards to other K8s resources
kubectl port-forward services/dapr-dashboard 8081:8080 -n dapr-system &
$RETURN
kubectl port-forward services/dashboard 7007:80 -n radius-system &
$RETURN

open -a "Microsoft Edge" "http://localhost:8081/overview/backend"
open -a "Microsoft Edge" "http://localhost:8087"
open -a "Microsoft Edge" "http://localhost:7007/resources/ateam/Applications.Core/applications/demo02/application"

#find all processes named 'kubectl' and terminate them:
killall kubectl
rad app delete demo02 --group ateam -y
