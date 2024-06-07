cd ..
rad deploy ./app.bicep --group test --environment test

wt %cd%\scripts\portforwards.bat

explorer http://localhost:8081/overview/backend
explorer http://localhost:8087/
explorer http://localhost:7007/resources/test/Applications.Core/applications/demo02/application

wt %cd%\scripts\kill_portforwards.bat