#!/bin/bash

az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_WANTED_NAME" \
  --location eastus2 \
  --sku Basic \
  --admin-enabled false \
  --public-network-enabled true

az containerapp env create \
  --name $DAPR_ENVIRONMENT_WANTED_NAME \
  --resource-group $RESOURCE_GROUP \
  --location eastus2

# Create basic Service Bus namespace (cheapest tier)
az servicebus namespace create \
  --resource-group $RESOURCE_GROUP \
  --name $ASB_NAMESPACE \
  --location "East US" \
  --sku Basic

az servicebus queue create \
  --resource-group $RESOURCE_GROUP \
  --namespace-name $ASB_NAMESPACE \
  --name $ASB_QUEUE

# Get the Service Bus namespace name and construct the full endpoint
ASB_NAMESPACE_ENDPOINT=$(az servicebus namespace list --resource-group $RESOURCE_GROUP --query '[0].serviceBusEndpoint' --output tsv)

# Alternative approach - get namespace name and construct endpoint
ASB_NAMESPACE_NAME=$(az servicebus namespace list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)
ASB_NAMESPACE_ENDPOINT="${ASB_NAMESPACE_NAME}.servicebus.windows.net"

DAPR_ENVIRONMENT_NAME=$(az containerapp env list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)

# Create managed identity
az identity create \
  --resource-group $RESOURCE_GROUP \
  --name $DAPR_AD_IDENTITY \
  --location eastus2

# Get the client ID
AZURE_CLIENT_ID=$(az identity show \
  --resource-group $RESOURCE_GROUP \
  --name $DAPR_AD_IDENTITY \
  --query clientId \
  --output tsv)

# Get the principal ID (needed for role assignment)
PRINCIPAL_ID=$(az identity show \
  --resource-group $RESOURCE_GROUP \
  --name $DAPR_AD_IDENTITY \
  --query principalId \
  --output tsv)

# Assign Service Bus Data Owner role to the managed identity
az role assignment create \
  --assignee $PRINCIPAL_ID \
  --role "Azure Service Bus Data Owner" \
  --scope "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.ServiceBus/namespaces/$ASB_NAMESPACE"

# Create Service Bus Dapr component YAML
echo "componentType: pubsub.azure.servicebus.queues
version: v1
ignoreErrors: false
metadata:
- name: namespaceName
  value: $ASB_NAMESPACE_ENDPOINT
- name: azureClientId
  value: $AZURE_CLIENT_ID" > dapr-servicebus.yaml

az containerapp env dapr-component set \
  --name $DAPR_ENVIRONMENT_NAME \
  --resource-group $RESOURCE_GROUP \
  --dapr-component-name $DAPR_COMPONENT_NAME \
  --yaml dapr-servicebus.yaml

# make sure ACR can be used by ACA
az containerapp env identity assign --name $DAPR_ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --system-assigned

ACA_IDENTITY_ID=$(az containerapp env show --name $DAPR_ENVIRONMENT_NAME --resource-group $RESOURCE_GROUP --query 'identity.principalId' --output tsv)

ACR_NAME=$(az acr list --resource-group $RESOURCE_GROUP --query '[0].name' --output tsv)
ACR_RESOURCE_ID=$(az acr show --name $ACR_NAME --resource-group $RESOURCE_GROUP --query 'id' --output tsv)

az role assignment create \
  --assignee $ACA_IDENTITY_ID \
  --role AcrPull \
  --scope $ACR_RESOURCE_ID