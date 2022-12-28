param location string

@allowed([
  'tst'
  'acc'
  'prd'
])
param environmentType string

param resourceNamePrefix string

param resourceTags object

param sqlServerName string
param sqlServerId string

var vnetName  = '${resourceNamePrefix}-vnet'
var subnetSqlName  = '${resourceNamePrefix}-sql-sn'
var subnetWebAppName  = '${resourceNamePrefix}-web-sn'
var privateDnsZoneName = 'privatelink${environment().suffixes.sqlServerHostname}'
var privateEndpointName = '${sqlServerName}-plink'

resource vnet 'Microsoft.Network/virtualNetworks@2022-07-01' = {
  name: vnetName
  location: location
  tags: resourceTags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.1.0.0/16'
      ]
    }
  }
}

resource subnetWebApp 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet  
  name: subnetWebAppName
  properties: {
    addressPrefix: '10.1.0.0/24'
    delegations: [
      {
        name: 'delegation'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]
  }
}

resource subnetSql 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  parent: vnet
  name: subnetSqlName
  properties: {
    addressPrefix: '10.1.1.0/24'
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2022-07-01' = if (environmentType == 'prd') {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetSql.id
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointName
        properties: {
          privateLinkServiceId: sqlServerId
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
}

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    vnet
  ]
}

resource privateDnsZoneLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${privateDnsZoneName}${uniqueString(vnet.id)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnet.id
    }
  }
}

resource privateEndpointDnsGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2022-07-01' = {
  name: '${privateEndpointName}/default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpoint
  ]
}

output subnetWebAppId string = subnetWebApp.id
