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

@secure()
param sqlServerAdministratorLogin string
@secure()
param sqlServerAdministratorPassword string

var resourceNamePrefix = '${customerName}-${projectName}-${environmentType}'
var sqlServerName = '${resourceNamePrefix}-sql'
var sqlDatabaseName = '${resourceNamePrefix}-db'
var sqlDatabaseSku = {
  name: 'S0'
  tier: 'Standard'
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  tags: resourceTags
  properties: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
  resource firewallRule 'firewallRules@2021-11-01' = {
    name: 'AllowTFEIP'
    properties: {
      startIpAddress: '91.206.137.194'
      endIpAddress: '91.206.137.194'
    }
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-11-01' = {
  parent: sqlServer
  name: sqlDatabaseName
  location: location
  tags: resourceTags
  sku: sqlDatabaseSku
}

/* Example of conditions. 

  resource auditStorageAccount 'Microsoft.Storage/storageAccounts@2021-09-01' = if (auditingEnabled) {
  name: auditStorageAccountName
  location: location
  sku: {
    name: auditStorageAccountSkuName
  }
  kind: 'StorageV2'  
} */

/* param sqlServerDetails array = [
  {
    name: 'sqlserver-we'
    location: 'westeurope'
    environmentName: 'Production'
  }
  {
    name: 'sqlserver-eus2'
    location: 'eastus2'
    environmentName: 'Development'
  }
  {
    name: 'sqlserver-eas'
    location: 'eastasia'
    environmentName: 'Production'
  }
]

resource sqlServers 'Microsoft.Sql/servers@2021-11-01-preview' = [for sqlServer in sqlServerDetails: if (sqlServer.environmentName == 'Production') {
  name: sqlServer.name
  location: sqlServer.location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
  tags: {
    environment: sqlServer.environmentName
  }
}] */
