cd ..
rad workspace list
rad workspace switch local
rad deploy ./frontend.bicep --parameters hostName=localhost --parameters useHttps=true

wt %cd%\scripts\portforwards.bat

curl -vk https://localhost
curl -vk https://localhost/api/gasinstore

explorer http://localhost
explorer http://localhost:16686

wt %cd%\scripts\kill_portforwards.bat

