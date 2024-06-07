cd ..
rad workspace list
rad workspace switch local

rad group list
rad group create test

rad run ./app.bicep --group test --application demo01

rad env show test -o json