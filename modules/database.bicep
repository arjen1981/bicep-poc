param location string

@allowed([
  'tst'
  'acc'
  'prd'
])
param environmentType string

param resourceNamePrefix string

param resourceTags object

@secure()
param sqlServerAdministratorLogin string
@secure()
param sqlServerAdministratorPassword string

var sqlServerName = '${resourceNamePrefix}-sql'
var sqlDatabaseName = '${resourceNamePrefix}-db'
var sqlDatabaseSku = {
  name: 'S0'
  tier: 'Standard'
}

var environmentConfigurationMap = {
  tst: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
  acc: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
  }
  prd: {
    administratorLogin: sqlServerAdministratorLogin
    administratorLoginPassword: sqlServerAdministratorPassword
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-11-01' = {
  name: sqlServerName
  location: location
  tags: resourceTags
  properties: environmentConfigurationMap[environmentType]
  resource firewallRule 'firewallRules@2021-11-01' = if (environmentType != 'prd') {
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

output sqlServerId string = sqlServer.id
output sqlServerName string = sqlServerName
