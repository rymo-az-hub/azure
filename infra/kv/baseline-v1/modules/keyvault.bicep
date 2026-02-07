targetScope = 'resourceGroup'

param location string
param keyVaultName string
param tags object

@description('Soft delete retention in days. (Soft delete is default-on in modern Key Vault)')
param softDeleteRetentionInDays int = 90

@description('Purge protection is irreversible once enabled. Baseline default is true.')
param enablePurgeProtection bool = true

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
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enablePurgeProtection: enablePurgeProtection

    // Network baseline (Private Endpoint only)
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'None'
      defaultAction: 'Deny'
    }
  }
}

output keyVaultId string = kv.id
