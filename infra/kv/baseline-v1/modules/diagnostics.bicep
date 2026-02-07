targetScope = 'resourceGroup'

@description('Target Key Vault resource id')
param keyVaultId string

@description('Log Analytics Workspace resource id')
param logAnalyticsWorkspaceId string

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  scope: resourceGroup()
  name: last(split(keyVaultId, '/'))
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
