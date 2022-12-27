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
/* @minLength(5)
@maxLength(30) */
param customerName string

@description('The project name.')
param projectName string

@description('The tags that will be set for each resource in this deployment. This parameter is specified as an objects of Tags: key value pair.')
param resourceTags object = {
  Customer: customerName
  Project: projectName
  Team: 'awsome team'
}

module storage 'modules/storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    environmentType: environmentType
    customerName: customerName
    projectName: projectName
    resourceTags: resourceTags
  }
}

module appService 'modules/appService.bicep' = {
  name: 'appService'
  params: {
    location: location
    environmentType: environmentType
    customerName: customerName
    projectName: projectName
    resourceTags: resourceTags
  }
}

output appServiceAppHostName string = appService.outputs.appServiceAppHostName
