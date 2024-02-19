targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param resourceGroupName string = ''

param searchServiceName string = ''
param searchServiceResourceGroupName string = ''
param searchServiceLocation string = ''
// The free tier does not support managed identity (required) or semantic search (optional)
@allowed([ 'free', 'basic', 'standard', 'standard2', 'standard3', 'storage_optimized_l1', 'storage_optimized_l2' ])
param searchServiceSkuName string // Set in main.parameters.json
param searchIndexName string // Set in main.parameters.json
param searchServiceSemanticRankerLevel string // Set in main.parameters.json
var actualSearchServiceSemanticRankerLevel = (searchServiceSkuName == 'free') ? 'disabled' : searchServiceSemanticRankerLevel
param useSearchServiceKey bool = searchServiceSkuName == 'free'

param storageAccountName string = ''
param keyVaultResourceGroupName string = ''
param storageResourceGroupName string = ''
param storageResourceGroupLocation string = location
param storageContainerName string = 'content'
param storageSkuName string // Set in main.parameters.json

@allowed([ 'azure', 'openai' ])
param openAiHost string // Set in main.parameters.json

param openAiServiceName string = ''
param openAiResourceGroupName string = ''
param useGPT4V bool = false

param computerVisionSecretName string = 'computerVisionSecret'
param searchServiceSecretName string = 'searchServiceSecret'

@description('Location for the OpenAI resource group')
@allowed([ 'canadaeast', 'eastus', 'eastus2', 'francecentral', 'switzerlandnorth', 'uksouth', 'japaneast', 'northcentralus', 'australiaeast', 'swedencentral' ])
@metadata({
  azd: {
    type: 'location'
  }
})
param openAiResourceGroupLocation string

param openAiSkuName string = 'S0'

param openAiApiKey string = ''
param openAiApiOrganization string = ''

param formRecognizerServiceName string = ''
param formRecognizerResourceGroupName string = ''
param formRecognizerResourceGroupLocation string = location
param formRecognizerSkuName string = 'S0'

param computerVisionServiceName string = ''
param computerVisionResourceGroupName string = ''
param computerVisionResourceGroupLocation string = 'eastus' // Vision vectorize API is yet to be deployed globally
param computerVisionSkuName string = 'S1'

param chatGptDeploymentName string // Set in main.parameters.json
param chatGptDeploymentCapacity int = 30
param chatGpt4vDeploymentCapacity int = 10
param chatGptModelName string = 'gpt-35-turbo'
param chatGptModelVersion string = '0301'
param embeddingDeploymentName string // Set in main.parameters.json
param embeddingDeploymentCapacity int = 30
param embeddingModelName string = 'text-embedding-ada-002'
param gpt4vModelName string = 'gpt-4'
param gpt4vDeploymentName string = 'gpt-4v'
param gpt4vModelVersion string = 'vision-preview'

param tenantId string = tenant().tenantId

// get your principalId from the output of the following command:
// az ad signed-in-user show
@description('Id of the user or app to assign application roles')
@metadata({
  azd: {
    type: 'string'
  }
})
param principalId string

var abbrs = loadJsonContent('abbreviations.json')
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))
var tags = { 'azd-env-name': environmentName }

// Organize resources in a resource group
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

var defaultOpenAiDeployments = [
  {
    name: chatGptDeploymentName
    model: {
      format: 'OpenAI'
      name: chatGptModelName
      version: chatGptModelVersion
    }
    sku: {
      name: 'Standard'
      capacity: chatGptDeploymentCapacity
    }
  }
  {
    name: embeddingDeploymentName
    model: {
      format: 'OpenAI'
      name: embeddingModelName
      version: '2'
    }
    sku: {
      name: 'Standard'
      capacity: embeddingDeploymentCapacity
    }
  }
]

var openAiDeployments = concat(defaultOpenAiDeployments, useGPT4V ? [
    {
      name: gpt4vDeploymentName
      model: {
        format: 'OpenAI'
        name: gpt4vModelName
        version: gpt4vModelVersion
      }
      sku: {
        name: 'Standard'
        capacity: chatGpt4vDeploymentCapacity
      }
    }
  ] : [])

module openAi 'core/ai/cognitiveservices.bicep' = if (openAiHost == 'azure') {
  name: 'openai'
  scope: resourceGroup
  params: {
    name: '${abbrs.cognitiveServicesAccounts}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: openAiSkuName
    }
    deployments: openAiDeployments
  }
}

// FormRecognizer is a.k.a Document Intelligence
// https://learn.microsoft.com/en-us/azure/ai-services/create-account-bicep?tabs=CLI
module formRecognizer 'core/ai/cognitiveservices.bicep' = {
  name: 'formrecognizer'
  scope: resourceGroup
  params: {
    name: '${abbrs.cognitiveServicesFormRecognizer}${resourceToken}'
    kind: 'FormRecognizer'
    location: location
    tags: tags
    sku: {
      name: formRecognizerSkuName
    }
  }
}

module searchService 'core/search/search-services.bicep' = {
  name: 'search-service'
  scope: resourceGroup
  params: {
    name: 'gptkb-${resourceToken}'
    location: location
    tags: tags
    authOptions: {
      aadOrApiKey: {
        aadAuthFailureMode: 'http401WithBearerChallenge'
      }
    }
    sku: {
      name: searchServiceSkuName
    }
    semanticSearch: actualSearchServiceSemanticRankerLevel
  }
}

module storage 'core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: resourceGroup
  params: {
    name: '${abbrs.storageStorageAccounts}${resourceToken}'
    location: location
    tags: tags
    allowBlobPublicAccess: false
    publicNetworkAccess: 'Enabled'
    sku: {
      name: storageSkuName
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 2
    }
    containers: [
      {
        name: storageContainerName
        publicAccess: 'None'
      }
    ]
  }
}

module containerRegistry 'core/host/container-registry.bicep' = {
  name: '${abbrs.containerRegistryRegistries}${resourceToken}'
  scope: resourceGroup
  params: {
    location: location
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
  }
}

module keyVault 'core/security/keyvault.bicep' = {
  name: '${abbrs.keyVaultVaults}${resourceToken}'
  scope: resourceGroup
  params: {
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    location: location
  }
}

module logAnalyticsWorkspace 'core/monitor/loganalytics.bicep' = {
  name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
  scope: resourceGroup
  params: {
    name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    location: location
  }
}

module applicationInsights 'core/monitor/applicationinsights.bicep' = {
  name: '${abbrs.insightsComponents}${resourceToken}'
  scope: resourceGroup
  params: {
    name: '${abbrs.insightsComponents}${resourceToken}'
    location: location
    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
  }
}

// Creates new Azure AI Studio project
module aiResource 'core/ai/ai-studio.bicep' = {
  name: 'ai-${abbrs.machineLearningServicesWorkspaces}${resourceToken}'
  scope: resourceGroup
  params: {
    // workspace organization
    aiResourceName: 'ai-${abbrs.machineLearningServicesWorkspaces}${resourceToken}'
    aiResourceFriendlyName: '${resourceGroupName}-hub'
    aiResourceDescription: 'AI Studio Hub for ${resourceGroupName}'
    aiProjectName: 'my-project'
    location: location
    tags: tags

    // dependent resources
    applicationInsightsId: applicationInsights.outputs.id
    containerRegistryId: containerRegistry.outputs.id
    keyVaultId: keyVault.outputs.id
    storageAccountId: storage.outputs.id

  }
}

// USER ROLES
/*
Read access to view files, models, deployments. The ability to create completion and embedding calls.
https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#cognitive-services-openai-user
*/
module openAiRoleUser 'core/security/role.bicep' = if (openAiHost == 'azure') {
  scope: resourceGroup
  name: 'openai-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '5e0bd9bd-7b93-4f28-af87-19fc36ad61bd'
    principalType: 'User'
  }
}

/*
Lets you read and list keys of Cognitive Services.
https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#cognitive-services-user
*/
module formRecognizerRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'formrecognizer-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'a97b65f3-24c7-4388-baec-2e87135dc908'
    principalType: 'User'
  }
}

/*
Read and list Azure Storage containers and blobs. To learn which actions are required for a given data operation, see Permissions for calling blob and queue data operations.
https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-reader
https://learn.microsoft.com/en-us/rest/api/storageservices/authenticate-with-azure-active-directory#permissions-for-calling-blob-and-queue-data-operations
*/

module storageRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'storage-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
    principalType: 'User'
  }
}

/*
Read, write, and delete Azure Storage containers and blobs. To learn which actions are required for a given data operation, see Permissions for calling blob and queue data operations.
https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#storage-blob-data-contributor
*/
module storageContribRoleUser 'core/security/role.bicep' = {
  scope: resourceGroup
  name: 'storage-contribrole-user'
  params: {
    principalId: principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'User'
  }
}

// Only create if using managed identity (non-free tier)
/*
Grants read access to Azure Cognitive Search index data.
https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#search-index-data-reader
*/
module searchRoleUser 'core/security/role.bicep' = if (!useSearchServiceKey) {
  scope: resourceGroup
  name: 'search-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '1407120a-92aa-4202-b7e9-c0e197c71c8f'
    principalType: 'User'
  }
}

/*
Grants full access to Azure Cognitive Search index data.
https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#search-index-data-contributor
*/

module searchContribRoleUser 'core/security/role.bicep' = if (!useSearchServiceKey) {
  scope: resourceGroup
  name: 'search-contrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '8ebe5a00-799e-43f5-93ac-243d3dce84a7'
    principalType: 'User'
  }
}

/*
Lets you manage Search services, but not access to them.
https://learn.microsoft.com/en-us/azure/role-based-access-control/built-in-roles#search-service-contributor
*/
module searchSvcContribRoleUser 'core/security/role.bicep' = if (!useSearchServiceKey) {
  scope: resourceGroup
  name: 'search-svccontrib-role-user'
  params: {
    principalId: principalId
    roleDefinitionId: '7ca78c08-252a-4471-8644-bb5ff32d4ba0'
    principalType: 'User'
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenantId
output AZURE_RESOURCE_GROUP string = resourceGroup.name

// Shared by all OpenAI deployments
output OPENAI_HOST string = openAiHost
output AZURE_OPENAI_EMB_MODEL_NAME string = embeddingModelName
output AZURE_OPENAI_CHATGPT_MODEL string = chatGptModelName
output AZURE_OPENAI_GPT4V_MODEL string = gpt4vModelName

// Specific to Azure OpenAI
output AZURE_OPENAI_SERVICE string = openAi.outputs.name
output AZURE_OPENAI_CHATGPT_DEPLOYMENT string = chatGptDeploymentName
output AZURE_OPENAI_EMB_DEPLOYMENT string = embeddingDeploymentName
output AZURE_OPENAI_GPT4V_DEPLOYMENT string = gpt4vDeploymentName
output AZURE_SEARCH_SERVICE_ENDPOINT string = searchService.outputs.endpoint
output AZURE_OPENAI_ENDPOINT string = openAi.outputs.endpoint
output AZURE_OPENAI_API_KEY string = openAi.outputs.apiKey
output AZURE_OPENAI_API_VERSION string = openAi.outputs.apiVersion

output AZURE_FORMRECOGNIZER_SERVICE string = formRecognizer.outputs.name
output AZURE_FORMRECOGNIZER_ENDPOINT string = formRecognizer.outputs.endpoint
output AZURE_FORMRECOGNIZER_API_KEY string = formRecognizer.outputs.apiKey
output AZURE_FORMRECOGNIZER_API_VERSION string = formRecognizer.outputs.apiVersion

output AZURE_SEARCH_INDEX string = searchIndexName
output AZURE_SEARCH_SERVICE string = searchService.outputs.name
output AZURE_SEARCH_SECRET_NAME string = useSearchServiceKey ? searchServiceSecretName : ''
output AZURE_SEARCH_SEMANTIC_RANKER string = actualSearchServiceSemanticRankerLevel
output AZURE_SEARCH_API_KEY string = searchService.outputs.apiKey

output AZURE_STORAGE_ACCOUNT string = storage.outputs.name
output AZURE_STORAGE_CONTAINER string = storageContainerName
output AZURE_STORAGE_CONNECTION_STRING string = storage.outputs.connectionString
