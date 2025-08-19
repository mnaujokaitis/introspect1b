#!/bin/bash

source variables.sh

DAPR_ENVIRONMENT_NAME=$(az containerapp env list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)
ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)
ACR_LOGIN_SERVER=$(az acr list --resource-group $RESOURCE_GROUP --query '[0].loginServer' --output tsv)
IDENTITY_ID=$(az identity show --resource-group $RESOURCE_GROUP --name $DAPR_AD_IDENTITY --query id --output tsv)

az containerapp create \
  --name order-service-app \
  --resource-group $RESOURCE_GROUP \
  --environment $DAPR_ENVIRONMENT_NAME \
  --registry-server $ACR_LOGIN_SERVER \
  --image $ACR_LOGIN_SERVER/orderservice:latest \
  --enable-dapr \
  --dapr-app-id order-service \
  --dapr-app-port 3000 \
  --min-replicas 1 \
  --max-replicas 1 \
  --user-assigned $IDENTITY_ID

az containerapp create \
  --name product-service-app \
  --resource-group $RESOURCE_GROUP \
  --environment $DAPR_ENVIRONMENT_NAME \
  --registry-server $ACR_LOGIN_SERVER \
  --image $ACR_LOGIN_SERVER/productservice:latest \
  --enable-dapr \
  --dapr-app-id product-service \
  --dapr-app-port 3000 \
  --ingress external \
  --target-port 3000 \
  --user-assigned $IDENTITY_ID