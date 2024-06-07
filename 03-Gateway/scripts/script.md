#Show app.bicep file
cd ..
rad workspace switch local
rad group create test
rad deploy ./app.bicep --group test


#call blue API
curl -HHost:test.loekd.com http://localhost/blue/api/color/

#call green API
curl -HHost:test.loekd.com http://localhost/api/color

#call the main site
curl -HHost:test.loekd.com http://localhost

#clean app
rad app delete demo03 -y