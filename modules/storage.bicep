param location string

@allowed([
  'tst'
  'acc'
  'prd'
])
param environmentType string

param resourceNamePrefix string

param resourceTags object

var storageAccountName = '${resourceNamePrefix}storage'
var storageAccountSkuName = (environmentType == 'prd') ? 'Standard_LRS' : 'Standard_LRS'

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
