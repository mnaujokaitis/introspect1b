#!/bin/bash

# Source the variables file
source variables.sh

STORAGE_ACCOUNT_NAME=$(az storage account list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)
STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' --output tsv)
DAPR_ENVIRONMENT_NAME=$(az containerapp env list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)

echo "apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: $DAPR_COMPONENT_NAME
spec:
  type: $DAPR_COMPONENT_NAME.azure.storagequeues
  version: v1
  metadata:
  - name: storageAccount
    value: '$STORAGE_ACCOUNT_NAME'
  - name: storageAccessKey
    value: '$STORAGE_ACCOUNT_KEY'" > dapr.yaml

az containerapp env dapr-component set --name $DAPR_ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --dapr-component-name pubsub --yaml dapr.yaml