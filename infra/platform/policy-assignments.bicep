targetScope = 'subscription'

@description('Allowed locations policy definition ID')
param allowedLocationsPolicyDefinitionId string

@description('Required tag policy definition ID (Require a tag on resources)')
param requireTagPolicyDefinitionId string

@description('Required tag policy definition ID (Require a tag on resource groups)')
param requireTagOnResourceGroupsPolicyDefinitionId string

@description('Allowed Azure regions')
param allowedLocations array = [
  'japaneast'
  'japanwest'
]

@description('Required tag names')
param requiredTagNames array = [
  'Owner'
  'CostCenter'
  'Environment'
]

resource allowedLocationsAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'pa-allowed-locations'
  properties: {
    displayName: 'Allowed locations (Japan East/West)'
    policyDefinitionId: allowedLocationsPolicyDefinitionId
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
  }
}

resource requireTagAssignments 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for tag in requiredTagNames: {
  name: 'pa-require-tag-${toLower(tag)}'
  properties: {
    displayName: 'Require tag: ${tag}'
    policyDefinitionId: requireTagPolicyDefinitionId
    parameters: {
      tagName: {
        value: tag
      }
    }
  }
}]

resource requireRgTagAssignments 'Microsoft.Authorization/policyAssignments@2022-06-01' = [for tag in requiredTagNames: {
  name: 'pa-require-rg-tag-${toLower(tag)}'
  properties: {
    displayName: 'Require RG tag: ${tag}'
    policyDefinitionId: requireTagOnResourceGroupsPolicyDefinitionId
    parameters: {
      tagName: {
        value: tag
      }
    }
  }
}]
