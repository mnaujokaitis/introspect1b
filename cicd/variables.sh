#!/bin/bash

export RESOURCE_GROUP="introspect1b"

export STORAGE_ACCOUNT_WANTED_NAME="mantasintrospect1stdapr2"
export ACR_WANTED_NAME="mantasintrospect1acr1"

export ASB_NAMESPACE="introspect1b-servicebus"
export ASB_QUEUE="introspect1b-dapr-queue"

export DAPR_ENVIRONMENT_WANTED_NAME="introspect1bdaprenv"
export DAPR_COMPONENT_NAME="pubsub"

export DAPR_AD_IDENTITY="dapr-servicebus-identity"