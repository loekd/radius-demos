cd ..

rad workspace switch local
rad deploy ./frontend.bicep -g test --parameters hostName=localhost --parameters useHttps=true

wt $PWD\scripts\portforwards.bat

#curl -k https://localhost
#check api health
curl -k https://localhost/api/healthz

explorer http://localhost
explorer http://localhost:16686
explorer http://localhost:7007/resources/test/Applications.Core/applications/demo04/application

wt $PWD\scripts\kill_portforwards.bat

