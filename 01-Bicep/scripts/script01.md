cd ..
rad workspace list
rad workspace switch local

rad group create test
rad group show test -o json

rad run ./app_v1.bicep --group test --application demo01
$CTRL+C

rad app delete demo01 --group test -y