cd ..

rad deploy ./app_v2.bicep --group test --application demo01
rad resource expose --group test --application demo01 containers container01 --port 3000 --remote-port 3000
$CTRL+C

rad env show test --group test -o json
rad app delete demo01 --group test -y