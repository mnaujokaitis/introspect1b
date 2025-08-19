## Documentation
[Read about architecture and test results](docs/arch_and_test.pdf)
This is brief documented depictid crucial details about architecture and test evidences.

[Some genAI usage examples](docs/genAI_usage.pdf)

[Azure resources exported template](docs/azure_resources.json)
This resources template was automatically built using, but it might be useful in case you 
are interested in detailed view. 
```bash
az group export --name $RESOURCE_GROUP
```

# Environment set-up
### 1. Azure CLI login

```bash
# make sure you are logged in to Azure
az login
```

### 2. Configuration
Open cicd/variables.sh and configure names for resources in your environment - set a unique resource group at least. 
Resource group of same name must be separately created (e.g. using Azure portal).
The rest of resources will be created by the scripts.

### 3. Run scripts from cicd directory to build docker images, create azure resources and start running ccontainer apps
Here are the scripts to get the environment up and running.

First time execution of Azure CLI might require installing extensions for Azure offerings like container apps - say yes.
```bash
# set up infrastructure - it will take multiple minutes
cd cicd
chmod +x infra.sh
./infra.sh

# while on cicd folder, allow executing .sh scripts - in some systems this needs explicit permission
chmod +x variables.sh
chmod +x build_publish.sh
chmod +x deploy.sh

# build order-service docker image, publish to Azure Container Registry
cd ../order-service
source ../cicd/variables.sh
../cicd/build_publish.sh "orderservice"

# build product-service docker image, publish to Azure Container Registry
cd ../product-service
source ../cicd/variables.sh
../cicd/build_publish.sh "productservice"

# deploy services
cd ../cicd
./deploy.sh
```

# Test
Use this curl and azure CLI combination to invoke the produce-service API through public internet.
Payload must have the three fields: productId, quantity, customerId
```bash
curl -X POST https://$(az containerapp show --name product-service-app --resource-group $RESOURCE_GROUP --query properties.configuration.ingress.fqdn --output tsv)/order-products \
-H "Content-Type: application/json" \
-d '{"productId": "123", "quantity": 2, "customerId": "456"}'
```

This will return a response like this:
```json
{"message":"Order created and event published"}
```

Order-service log can be viewed going to container app in Azure portal, go to "Logs stream" blade on the left.