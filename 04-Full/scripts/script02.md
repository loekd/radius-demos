cd ..
rad workspace list
rad workspace switch cloud
rad group create prod

rad deploy ./frontend.bicep --parameters environmentName=prod --parameters hostName=demo.loekd.com

#check api health
curl https://demo.loekd.com/api/healthz

explorer https://demo.loekd.com/dispatch

explorer https://portal.azure.com/#@loekd.com/resource/subscriptions/6eb94a2c-34ac-45db-911f-c21438b4939c/resourceGroups/rg-radius/providers/Microsoft.ServiceBus/namespaces/sb-dispatchpubsub/overview

explorer https://portal.azure.com/#@loekd.com/resource/subscriptions/6eb94a2c-34ac-45db-911f-c21438b4939c/resourceGroups/rg-radius/providers/Microsoft.DocumentDB/databaseAccounts/cos-ceeb2yom4hrla/overview

explorer https://portal.azure.com/#@loekd.com/resource/subscriptions/6eb94a2c-34ac-45db-911f-c21438b4939c/resourceGroups/rg-radius/providers/microsoft.insights/components/ai-radius/applicationMap

#revert
kubectl config use-context docker-desktop