targetScope = 'resourceGroup'

@description('Location for Log Analytics workspace.')
param location string = resourceGroup().location

@description('Log Analytics workspace name.')
param logAnalyticsWorkspaceName string

@minValue(30)
@maxValue(730)
@description('Workspace retention in days (30-730).')
param retentionInDays int = 30

@description('Tags required by the baseline (Owner/CostCenter/Environment).')
param tags object

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2022-10-01' = {
  name: logAnalyticsWorkspaceName
  location: location
  tags: tags
  properties: {
    retentionInDays: retentionInDays
    features: {
      enableLogAccessUsingOnlyResourcePermissions: true
    }
  }
}

output workspaceId string = logAnalytics.id
output workspaceCustomerId string = logAnalytics.properties.customerId
