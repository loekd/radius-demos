#select workspace
rad workspace switch local

#create group
rad group create test

#prepare and run app
rad init --full
rad run ./app.bicep --group test

#Uncomment database resource and connection!

#run app again
rad run ./app.bicep --group test

#clean app
rad app delete demo01 -y