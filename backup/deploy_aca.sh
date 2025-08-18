#!/bin/bash

# Source the variables file
source variables.sh

echo $RESOURCE_GROUP

az storage account create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$STORAGE_ACCOUNT_WANTED_NAME" \
  --location eastus2 \
  --sku Standard_LRS \
  --kind StorageV2 \
  --access-tier Hot \
  --min-tls-version TLS1_2 \
  --allow-blob-public-access false \
  --allow-shared-key-access true \
  --https-only true \
  --bypass AzureServices \
  --default-action Allow

STORAGE_ACCOUNT_NAME=$(az storage account list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)
STORAGE_ACCOUNT_KEY=$(az storage account keys list --resource-group $RESOURCE_GROUP --account-name $STORAGE_ACCOUNT_NAME --query '[0].value' --output tsv)
DAPR_ENVIRONMENT_NAME=$(az containerapp env list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)

echo $DAPR_ENVIRONMENT_NAME

az storage queue create \
  --name "$DAPR_ORDER_QUEUE" \
  --account-name $STORAGE_ACCOUNT_NAME \
  --account-key $STORAGE_ACCOUNT_KEY

az containerapp env dapr-component set --name $DAPR_ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --dapr-component-name $DAPR_COMPONENT_NAME --yaml "./dapr.yaml"

