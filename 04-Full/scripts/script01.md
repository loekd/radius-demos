cd ..

rad workspace switch local
rad deploy ./environments/test.bicep -g test
rad deploy ./app.bicep -g test --parameters hostName=localhost --parameters useHttps=true

wt $PWD\scripts\portforwards.bat

#curl -k https://localhost
#check api health
curl -k https://localhost/api/healthz

explorer https://localhost/dispatch 
explorer http://localhost:16686
explorer http://localhost:7007/resources/test/Applications.Core/applications/demo04/application

wt $PWD\scripts\kill_portforwards.bat

