cd ..

rad run ./app_v2.bicep --group test --application demo01
$CTRL+C

rad env show test -o json
rad app delete demo01 -y