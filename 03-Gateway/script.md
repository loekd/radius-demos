rad workspace switch local
rad group create test
rad deploy ./app.bicep --group test


#call blue API
curl http://localhost/blue/api/color/

#call green API
curl http://localhost/api/color

#call the main site
curl http://localhost

#clean app
rad app delete demo03 -y