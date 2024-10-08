#!/bin/sh

## Create a k3d cluster
while (! kubectl cluster-info ); do
  # Docker takes a few seconds to initialize
  echo "Waiting for Docker to launch..."
  k3d cluster delete
  k3d cluster create -p '8081:80@loadbalancer' --k3s-arg '--disable=traefik@server:0' --k3s-arg '--disable=servicelb@server:*'
  sleep 1
done

## Install Dapr and init
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash
dapr uninstall # clean if needed
dapr init -k

# #tools
# docker pull mongo:7.0
# docker pull bitnami/mongodb:6.0.2
# docker pull mongo-express
# docker pull redis
# docker pull redis
# docker pull redis/redisinsight:latest
# docker pull daprio/dashboard:latest
# docker pull daprio/daprd:1.13.1
# docker pull jaegertracing/all-in-one:1.6

# #application images
# docker pull acrradius.azurecr.io/missioncriticaldemo.dispatchapi:latest
# docker pull acrradius.azurecr.io/missioncriticaldemo.plantapi:latest
# docker pull acrradius.azurecr.io/missioncriticaldemo.frontend:latest

#Install Radius
rad install kubernetes

## hint to run the containers using radius
echo "Check out the numbered folders for exercises"

# disable commit signing locally
git config --local commit.gpgsign false
