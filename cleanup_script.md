kubectl config use-context aksradius-admin
rad workspace switch cloud

#revert patching
kubectl patch httpproxy dispatchapi -n prod-demo04 --type='json' -p='[{"op": "remove", "path": "/spec/routes/0/enableWebsockets"}]'


rad workspace switch local
kubectl config use-context docker-desktop

rad app delete demo00 -y
rad app delete demo01 -y
rad app delete demo02 -y
rad app delete demo03 -y
rad app delete demo04 -y

