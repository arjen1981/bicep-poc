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

var resourceNamePrefix = '${customerName}-${projectName}-${environmentType}'
var appServicePlanName = '${resourceNamePrefix}-plan'
var appServicePlanSkuName = (environmentType == 'prd') ? 'P2V3' : 'F1'
/* Example of an object type param.
param appServicePlanSku object = {
  name: 'F1'
  tier: 'Free'
  capacity: 1
} */
var appServiceAppName  = '${resourceNamePrefix}-web'

/* Example of how to use the minValue and maxValue to validate the value of an int.
@minValue(1)
@maxValue(10)
param appServicePlanInstanceCount int */

resource appServicePlan 'Microsoft.Web/serverFarms@2022-03-01' = {
  name: appServicePlanName
  location: location
  tags: resourceTags
  sku: {
    name: appServicePlanSkuName
  }
}

resource appServiceApp 'Microsoft.Web/sites@2022-03-01' = {
  name: appServiceAppName
  location: location
  tags: resourceTags
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
  }
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
