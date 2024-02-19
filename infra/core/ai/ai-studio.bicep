// Creates an Azure AI resource with proxied endpoints for the Azure AI services provider

@description('Azure region of the deployment')
param location string

@description('Tags to add to the resources')
param tags object

@description('AI resource name')
param aiResourceName string

@description('AI project name')
param aiProjectName string

@description('AI resource display name')
param aiResourceFriendlyName string = aiResourceName

@description('AI resource description')
param aiResourceDescription string

@description('Resource ID of the application insights resource for storing diagnostics logs')
param applicationInsightsId string

@description('Resource ID of the container registry resource for storing docker images')
param containerRegistryId string

@description('Resource ID of the key vault resource for storing connection strings')
param keyVaultId string

@description('Resource ID of the storage account resource for storing experimentation outputs')
param storageAccountId string

resource aiResource 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: aiResourceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    // workspace organization
    friendlyName: aiResourceFriendlyName
    description: aiResourceDescription

    // dependent resources
    keyVault: keyVaultId
    storageAccount: storageAccountId
    applicationInsights: applicationInsightsId
    containerRegistry: containerRegistryId
  }
  kind: 'hub'
}

resource aiProject 'Microsoft.MachineLearningServices/workspaces@2023-10-01' = {
  name: aiProjectName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hubResourceId: aiResource.id
  }
  kind: 'project'
}

output aiResourceID string = aiResource.id
