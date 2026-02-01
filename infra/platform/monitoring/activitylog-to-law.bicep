targetScope = 'subscription'

@description('Whether to create a new Log Analytics workspace (true) or use an existing workspaceId (false).')
param createLogAnalytics bool = true

@description('Resource group name for Log Analytics (only used when createLogAnalytics = true).')
param logAnalyticsRgName string = 'rg-platform-monitoring'

@allowed([
  'japaneast'
  'japanwest'
])
@description('Location for Log Analytics resources (must be within allowed locations baseline).')
param location string = 'japaneast'

@description('Log Analytics workspace name (only used when createLogAnalytics = true).')
param logAnalyticsWorkspaceName string = 'law-platform-baseline'

@minValue(30)
@maxValue(730)
@description('Workspace retention in days (30-730).')
param retentionInDays int = 30

@description('Existing Log Analytics workspace resourceId (required when createLogAnalytics = false).')
param existingWorkspaceId string = ''

@description('Tags required by the baseline (Owner/CostCenter/Environment).')
param tags object = {
  Owner: 'Ryosuke'
  CostCenter: '000'
  Environment: 'dev'
}

@description('Diagnostic settings name for Activity Log.')
param activityLogDiagName string = 'ds-activitylog-to-law'

/*
  Activity Log -> Log Analytics

  Evidence (CLI):
    az monitor diagnostic-settings subscription show --name <activityLogDiagName> -o jsonc
  Evidence (Portal/KQL):
    AzureActivity | take 5

  Notes:
    - Workspace is a resourceGroup-scope resource, so it must be deployed via a module.
    - logAnalyticsDestinationType is set to Dedicated so Activity Log lands in dedicated tables (e.g., AzureActivity).
*/

resource logRg 'Microsoft.Resources/resourceGroups@2021-04-01' = if (createLogAnalytics) {
  name: logAnalyticsRgName
  location: location
  tags: tags
}

module law './log-analytics.bicep' = if (createLogAnalytics) {
  name: 'law-${logAnalyticsWorkspaceName}'
  scope: resourceGroup(logAnalyticsRgName)
  params: {
    location: location
    logAnalyticsWorkspaceName: logAnalyticsWorkspaceName
    retentionInDays: retentionInDays
    tags: tags
  }
  dependsOn: [
    logRg
  ]
}

var workspaceId = createLogAnalytics ? law.outputs.workspaceId : existingWorkspaceId

// Guardrail for correctness (visible in outputs)
var workspaceIdGuard = (!createLogAnalytics && empty(existingWorkspaceId))
  ? 'ERROR: existingWorkspaceId is required when createLogAnalytics=false'
  : 'OK'

resource activityLogDiag 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: activityLogDiagName
  scope: subscription()
  properties: {
    // Force dedicated tables in Log Analytics (AzureActivity etc.)
    logAnalyticsDestinationType: 'Dedicated'
    workspaceId: workspaceId
    logs: [
      { category: 'Administrative', enabled: true, retentionPolicy: { enabled: false, days: 0 } }
      { category: 'Security', enabled: true, retentionPolicy: { enabled: false, days: 0 } }
      { category: 'ServiceHealth', enabled: true, retentionPolicy: { enabled: false, days: 0 } }
      { category: 'Alert', enabled: true, retentionPolicy: { enabled: false, days: 0 } }
      { category: 'Recommendation', enabled: true, retentionPolicy: { enabled: false, days: 0 } }
      { category: 'Policy', enabled: true, retentionPolicy: { enabled: false, days: 0 } }
      { category: 'Autoscale', enabled: true, retentionPolicy: { enabled: false, days: 0 } }
      { category: 'ResourceHealth', enabled: true, retentionPolicy: { enabled: false, days: 0 } }
    ]
    metrics: []
  }
}

output logAnalyticsWorkspaceId string = workspaceId
output diagnosticSettingsId string = activityLogDiag.id
output workspaceIdGuard string = workspaceIdGuard
