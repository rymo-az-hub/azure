targetScope = 'resourceGroup'

@description('Location for resources')
param location string = 'japaneast'

@description('Key Vault name (must be globally unique)')
param keyVaultName string

@allowed([
  'standard'
  'premium'
])
param skuName string = 'standard'

@description('Tags - Owner')
param tagOwner string
@description('Tags - CostCenter')
param tagCostCenter string
@description('Tags - Environment (dev/stg/prod etc)')
param tagEnvironment string

@description('Log Analytics Workspace name for diagnostics')
param lawName string = 'law-platform-baseline'
@description('Resource group of the Log Analytics Workspace')
param lawResourceGroup string = 'rg-platform-monitoring'

@description('Enable Key Vault metrics (AllMetrics) to LAW. Recommended: false in v1 unless you have a use-case.')
param enableMetrics bool = false

@description('Soft delete retention days (7-90). Default 90.')
@minValue(7)
@maxValue(90)
param softDeleteRetentionInDays int = 90

// Existing LAW (same subscription assumed)
resource law 'Microsoft.OperationalInsights/workspaces@2023-09-01' existing = {
  name: lawName
  scope: resourceGroup(lawResourceGroup)
}

// Key Vault
resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: {
    Owner: tagOwner
    CostCenter: tagCostCenter
    Environment: tagEnvironment
  }
  properties: {
    tenantId: subscription().tenantId

    // IMPORTANT: Use Azure RBAC (no access policies)
    enableRbacAuthorization: true

    // Network: Public access disabled
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
    }

    // Baseline hardening
    enablePurgeProtection: true
    softDeleteRetentionInDays: softDeleteRetentionInDays

    sku: {
      name: skuName
      family: 'A'
    }
  }
}

// Diagnostic Settings (AuditEvent + optionally AllMetrics)
resource kvDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'ds-kv-to-law'
  scope: kv
  properties: {
    workspaceId: law.id
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: enableMetrics
      }
    ]
  }
}
