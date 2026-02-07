targetScope = 'resourceGroup'

@description('Location for all resources')
param location string = resourceGroup().location

@description('Key Vault name (globally unique)')
param keyVaultName string

@description('Log Analytics Workspace resource id (for diagnostics)')
param logAnalyticsWorkspaceId string

@description('VNet resource id where Private DNS link will be created')
param vnetId string

@description('Subnet resource id for Private Endpoint (dedicated recommended)')
param privateEndpointSubnetId string

@description('Private Endpoint name')
param privateEndpointName string = 'pe-${keyVaultName}'

@description('Private DNS Zone name for Key Vault')
param privateDnsZoneName string = 'privatelink.vaultcore.azure.net'

@description('Tags (required by policy in this subscription)')
param tags object

@description('Optional: list of principal objectIds to assign Key Vault Administrator')
param kvAdmins array = []

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: subscription().tenantId
    sku: {
      family: 'A'
      name: 'standard'
    }

    // Authorization baseline
    enableRbacAuthorization: true
    enabledForDeployment: false
    enabledForDiskEncryption: false
    enabledForTemplateDeployment: false

    // Data protection baseline
    enableSoftDelete: true
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true

    // Network baseline (Private Endpoint only)
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
  }
}

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

resource pe 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndpointName
  location: location
  tags: tags
  properties: {
    subnet: {
      id: privateEndpointSubnetId
    }
    privateLinkServiceConnections: [
      {
        name: '${privateEndpointName}-kv'
        properties: {
          privateLinkServiceId: kv.id
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
          privateDnsZoneId: pdz.id
        }
      }
    ]
  }
}

resource kvDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diag-to-law'
  scope: kv
  properties: {
    workspaceId: logAnalyticsWorkspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: false
        retentionPolicy: {
          enabled: false
          days: 0
        }
      }
    ]
  }
}

// Optional RBAC assignments (Key Vault Administrator)
// principalType is intentionally not set to avoid mismatches (User/Group/SPN)
resource kvAdminRole 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for adminId in kvAdmins: {
  name: guid(kv.id, adminId, 'kv-admin')
  scope: kv
  properties: {
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '00482a5a-887f-4fb3-b363-3b7fe8e74483') // Key Vault Administrator
    principalId: adminId
  }
}]
