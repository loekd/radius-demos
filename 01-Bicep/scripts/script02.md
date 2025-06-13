clear
cd /Users/loekd/projects/radius-demos/01-Bicep

rad deploy ./app_v2.bicep --group ateam --environment test --application demo01
rad resource expose --group ateam --application demo01 Applications.Core/containers container01 --port 3000 --remote-port 3000
$CTRL+C

rad env show test --group ateam -o json
rad app delete demo01 --group ateam -y
