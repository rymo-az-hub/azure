targetScope = 'subscription'

@description('Budget name (subscription scope).')
param budgetName string = 'bg-platform-baseline-v1'

@description('Budget amount for the period (currency depends on subscription billing settings; typically USD).')
param amount int = 200

@allowed([
  'Monthly'
  'Quarterly'
  'Annually'
])
@description('Budget period.')
param timeGrain string = 'Monthly'

@description('Budget start date (ISO 8601). Example: 2026-02-01T00:00:00Z')
param startDate string = '2026-02-01T00:00:00Z'

@description('Budget end date (ISO 8601). Keep far-future for continuous operation.')
param endDate string = '2030-12-31T00:00:00Z'

@description('Notification email recipient (single address).')
param contactEmail string = 'replace-me@example.com'

@description('Threshold percentage for notification #1.')
param threshold1 int = 80

@description('Threshold percentage for notification #2.')
param threshold2 int = 100

/*
  Cost Management Budget (subscription scope)
  Evidence (CLI):
    az consumption budget show --name <budgetName> -o jsonc
*/

var contactEmails = [
  contactEmail
]

var notifications = {
  // NOTE: Object-comprehension is avoided for compatibility with older Bicep versions.
  Actual_GreaterThan_80_Percent: {
    enabled: true
    operator: 'GreaterThan'
    threshold: threshold1
    contactEmails: contactEmails
    contactRoles: []
    contactGroups: []
  }
  Actual_GreaterThan_100_Percent: {
    enabled: true
    operator: 'GreaterThan'
    threshold: threshold2
    contactEmails: contactEmails
    contactRoles: []
    contactGroups: []
  }
}

resource budget 'Microsoft.Consumption/budgets@2023-05-01' = {
  name: budgetName
  properties: {
    category: 'Cost'
    amount: amount
    timeGrain: timeGrain
    timePeriod: {
      startDate: startDate
      endDate: endDate
    }
    notifications: notifications
  }
}

output budgetId string = budget.id
