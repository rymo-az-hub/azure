targetScope = 'resourceGroup'

param location string
param privateEndpointName string
param subnetId string
param keyVaultId string
param privateDnsZoneId string
param tags object

resource pe 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-kv'
        properties: {
          privateLinkServiceId: keyVaultId
          groupIds: [
            'vault'
          ]
          requestMessage: 'Private Endpoint for Key Vault'
        }
      }
    ]
  }
}

resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  name: 'default'
  parent: pe
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'kv-dns'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}
