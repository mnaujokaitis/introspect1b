#!/bin/bash
ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query "[0].name" --output tsv)

az acr login --name $ACR_NAME
ACR_LOGIN_SERVER=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query "loginServer" --output tsv)

docker build --platform linux/amd64 -t $IMAGE_NAME .
docker tag $IMAGE_NAME $ACR_LOGIN_SERVER/$IMAGE_NAME:latest
docker push $ACR_LOGIN_SERVER/$IMAGE_NAME:latest