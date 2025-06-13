cd /Users/loekd/projects/radius-demos/04-Full
clear

rad workspace switch local
rad deploy ./environments/test.bicep -g ateam
rad deploy ./app.bicep -g ateam -e test --parameters hostName=localhost --parameters useHttps=true

#find jaeger service by its jaeger prefix, and forward a port to it:
kubectl port-forward services/$(kubectl get svc -n test-demo04 -o jsonpath="{range .items[*]}{.metadata.name}{'\n'}{end}" | grep "^jaeger-") 16686:16686 -n test-demo04 &
$RETURN
kubectl port-forward services/dashboard 7007:80 -n radius-system &
$RETURN

#check api health through gateway at localhost
curl -k https://localhost/api/healthz

open -a "Microsoft Edge" "https://localhost/dispatch"
open -a "Microsoft Edge" "http://localhost:16686"
open -a "Microsoft Edge" "http://localhost:7007/resources/ateam/Applications.Core/applications/demo04/application"


#find all processes named 'kubectl' and terminate them:
killall kubectl

rad app delete -n demo04 -g ateam -e test -y