param location string

@allowed([
  'tst'
  'acc'
  'prd'
])
param environmentType string

param resourceNamePrefix string

param resourceTags object

param subnetId string

var appServicePlanName = '${resourceNamePrefix}-plan'
var appServicePlanSkuName = (environmentType == 'prd') ? 'B1' : 'F1'
var appServiceAppName  = '${resourceNamePrefix}-web'

var environmentConfigurationMap = {
  tst: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      http20Enabled: true
    }
  }
  acc: {
    serverFarmId: appServicePlan.id
    httpsOnly: true
    siteConfig: {
      http20Enabled: true
    }
  }
  prd: {
    serverFarmId: appServicePlan.id
    virtualNetworkSubnetId: subnetId
    httpsOnly: true
    siteConfig: {
      vnetRouteAllEnabled: true
      http20Enabled: true
    }
  }
}

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
  properties: environmentConfigurationMap[environmentType]
}

output appServiceAppHostName string = appServiceApp.properties.defaultHostName
