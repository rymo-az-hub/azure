targetScope = 'resourceGroup'

@description('Location for resources')
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

@description('Tags (required by policy in this subscription)')
param tags object

@description('Soft delete retention in days')
param softDeleteRetentionInDays int = 90

@description('Purge protection is irreversible once enabled. Baseline default true.')
param enablePurgeProtection bool = true

// RBAC principals (optional)
param kvAdmins array = []
param secretsOfficers array = []
param secretsUsers array = []
param kvReaders array = []

module kv 'modules/keyvault.bicep' = {
  name: 'kv-core'
  params: {
    location: location
    keyVaultName: keyVaultName
    tags: tags
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection
  }
}

module dns 'modules/privateDns.bicep' = {
  name: 'kv-dns'
  params: {
    vnetId: vnetId
    tags: tags
  }
}

module pe 'modules/privateEndpoint.bicep' = {
  name: 'kv-pe'
  params: {
    location: location
    privateEndpointName: privateEndpointName
    subnetId: privateEndpointSubnetId
    keyVaultId: kv.outputs.keyVaultId
    privateDnsZoneId: dns.outputs.privateDnsZoneId
    tags: tags
  }
}

module diag 'modules/diagnostics.bicep' = {
  name: 'kv-diag'
  params: {
    keyVaultId: kv.outputs.keyVaultId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
  }
}

module rbac 'modules/rbac.bicep' = {
  name: 'kv-rbac'
  params: {
    keyVaultName: keyVaultName
    kvAdmins: kvAdmins
    secretsOfficers: secretsOfficers
    secretsUsers: secretsUsers
    kvReaders: kvReaders
  }
}
