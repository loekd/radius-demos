cd C:\Temp\radius\04-Full
rad workspace list
rad workspace switch aks
rad group create prod

rad recipe list -e prod
rad env show prod -o json
cls
#rad deploy ./frontend.bicep --parameters environmentName=prod --parameters hostName=demo.loekd.com

kubectl config use-context aksradius-admin
kubectl config set-context --current --namespace=prod-demo04

explorer https://demo.loekd.com

wt kubectl port-forward services/dashboard 7007:80 -n radius-system
explorer http://localhost:7007/resources/prod/Applications.Core/applications/demo04/application

explorer https://portal.azure.com/#@loekd.com/resource/subscriptions/6eb94a2c-34ac-45db-911f-c21438b4939c/resourceGroups/rg-radius/providers/Microsoft.ServiceBus/namespaces/sb-dispatchpubsub/overview

explorer https://portal.azure.com/#@loekd.com/resource/subscriptions/6eb94a2c-34ac-45db-911f-c21438b4939c/resourceGroups/rg-radius/providers/Microsoft.DocumentDB/databaseAccounts/cos-ceeb2yom4hrla/overview
