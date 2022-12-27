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
