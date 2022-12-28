param location string

@allowed([
  'tst'
  'acc'
  'prd'
])
param environmentType string

param customerName string
param projectName string

param resourceTags object

var storageAccountName = '${customerName}${projectName}${environmentType}storage'
/* Example of a function that can be used to generate a unique string based on the resource group id.
var storageAccountName string = '{customerName}${projectName}${environmentType}storage${uniqueString(resourceGroup().id)}'
All functions: https://learn.microsoft.com/en-us/azure/azure-resource-manager/bicep/bicep-functions */
var storageAccountSkuName = (environmentType == 'prd') ? 'Standard_GRS' : 'Standard_LRS'

resource storageAccount 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  tags: resourceTags
  sku: {
    name: storageAccountSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}
