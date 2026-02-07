targetScope = 'resourceGroup'

param privateDnsZoneName string = 'privatelink.vaultcore.azure.net'
param vnetId string
param tags object

resource pdz 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  tags: tags
}

resource vnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: 'link-${uniqueString(vnetId)}'
  parent: pdz
  location: 'global'
  tags: tags
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

output privateDnsZoneId string = pdz.id
