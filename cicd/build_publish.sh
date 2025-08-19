#!/bin/bash

# Check if IMAGE_NAME argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <IMAGE_NAME>"
    exit 1
fi

IMAGE_NAME=$1

ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query "[0].name" --output tsv)

az acr login --name $ACR_NAME
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)

docker build --platform linux/amd64 -t $IMAGE_NAME .
docker tag $IMAGE_NAME $ACR_LOGIN_SERVER/$IMAGE_NAME:latest
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:latest