#workspaces
rad workspace list
rad workspace show
rad workspace switch dev

#groups
rad group list
rad group create dev

#app
rad run ./app.bicep --group dev --application demo00
rad app show --application demo00

#clean
rad app delete demo00 -y
rad env delete dev -g dev -y
rad group delete dev -y