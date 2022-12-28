@description('The Azure region into which the resources should be deployed.')
param location string = resourceGroup().location

@description('The name of the environment. This must be tst, acc, or prd.')
@allowed([
  'tst'
  'acc'
  'prd'
])
param environmentType string

/* Alternativly you can use a map to define the environment configuration.
var environmentConfigurationMap = {
  Production: {
    appServicePlan: {
      sku: {
        name: 'P2V3'
        capacity: 3
      }
    }
    storageAccount: {
      sku: {
        name: 'ZRS'
      }
    }
  }
  Test: {
    appServicePlan: {
      sku: {
        name: 'S2'
        capacity: 1
      }
    }
    storageAccount: {
      sku: {
        name: 'LRS'
      }
    }
  }
}
*/

@description('The customer name.')
/* Example of how to use the minLength and maxLength to validate the length of a string.
@minLength(5)
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

@secure()
@description('The administrator login username for the SQL server.')
param sqlServerAdministratorLogin string

@secure()
@description('The administrator login password for the SQL server.')
param sqlServerAdministratorPassword string

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

module database 'modules/database.bicep' = {
  name: 'database'
  params: {
    location: location
    environmentType: environmentType
    customerName: customerName
    projectName: projectName
    resourceTags: resourceTags
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorPassword: sqlServerAdministratorPassword
  }
}

/* Example of using loops.
@description('The Azure regions into which the resources should be deployed.')
param locations array = [
  'westeurope'
  'eastus2'
]

@batchSize(1) // 1 if you dont want to run this loop parallel, which is more expensive
module databases 'modules/database.bicep' = [for location in locations: {
  name: 'database-${location}'
  params: {
    location: location
    environmentType: environmentType
    customerName: customerName
    projectName: projectName
    resourceTags: resourceTags
    sqlServerAdministratorLogin: sqlServerAdministratorLogin
    sqlServerAdministratorPassword: sqlServerAdministratorPassword
  }
}] */

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
