@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the environment. This must be tst, acc, or prd.')
@allowed([
  'tst'
  'acc'
  'prd'
])
param environmentType string

@description('The customer name.')

param customerName string

@description('The project name.')
param projectName string

@description('The tags that will be set for each resource in this deployment. This parameter is specified as an objects of Tags: key value pair.')
param resourceTags object = {
  Customer: customerName
  Project: projectName
  Team: 'awsome team'
}

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

var resourceNamePrefix = '${customerName}-${projectName}-${environmentType}'

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    environmentType: environmentType
    resourceNamePrefix: '${customerName}${projectName}${environmentType}'
    resourceTags: resourceTags
  }
}

module database 'modules/database.bicep' = {
  name: 'database'
  params: {
    location: location
    environmentType: environmentType
    resourceNamePrefix: resourceNamePrefix
    resourceTags: resourceTags
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorPassword: sqlServerAdministratorPassword
  }
}

module network 'modules/network.bicep' = if (environmentType == 'prd') {
  name: 'network'
  params: {
    location: location
    environmentType: environmentType
    resourceNamePrefix: resourceNamePrefix
    sqlServerId: database.outputs.sqlServerId
    sqlServerName: database.outputs.sqlServerName
    resourceTags: resourceTags
  }
  dependsOn: [
    database
  ]
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: environmentType
    resourceNamePrefix: resourceNamePrefix
    resourceTags: resourceTags
    subnetId: (environmentType == 'prd') ? network.outputs.subnetWebAppId : ''
  }
  dependsOn: (environmentType == 'prd') ? [network] : []
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
