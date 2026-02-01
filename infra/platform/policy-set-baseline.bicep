targetScope = 'subscription'

@description('Policy definition IDs (built-in)')
param allowedLocationsPolicyDefinitionId string
param requireTagPolicyDefinitionId string
param requireTagOnResourceGroupsPolicyDefinitionId string
param secureTransferPolicyDefinitionId string
param notAllowedResourceTypesPolicyDefinitionId string

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

@description('Denied resource types (Not allowed resource types policy)')
param deniedResourceTypes array = [
  'Microsoft.Network/publicIPAddresses'
]

@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param secureTransferEffect string = 'Deny'

@allowed([
  'Audit'
  'Deny'
  'Disabled'
])
param notAllowedResourceTypesEffect string = 'Deny'

/*
  Policy Set members (no initiative-level parameter references)
  -> Avoid ARM expression strings like "[parameters('x')]"
*/

/**
 * 既存indexを維持したいので、base は “最初からあった2つ” だけに固定
 */
var basePolicyDefs = [
  {
    policyDefinitionId: allowedLocationsPolicyDefinitionId
    policyDefinitionReferenceId: 'allowedLocations'
    parameters: {
      listOfAllowedLocations: {
        value: allowedLocations
      }
    }
  }
  {
    policyDefinitionId: secureTransferPolicyDefinitionId
    policyDefinitionReferenceId: 'secureTransferStorage'
    parameters: {
      effect: {
        value: secureTransferEffect
      }
    }
  }
]

var resourceTagPolicyDefs = [
  for tag in requiredTagNames: {
    policyDefinitionId: requireTagPolicyDefinitionId
    policyDefinitionReferenceId: 'requireTag-${toLower(tag)}'
    parameters: {
      tagName: {
        value: tag
      }
    }
  }
]

var rgTagPolicyDefs = [
  for tag in requiredTagNames: {
    policyDefinitionId: requireTagOnResourceGroupsPolicyDefinitionId
    policyDefinitionReferenceId: 'requireRgTag-${toLower(tag)}'
    parameters: {
      tagName: {
        value: tag
      }
    }
  }
]

/**
 * 追加ルールは末尾追加（indexシフトを起こさない）
 * 既存の並び (base -> resourceTags -> rgTags) をまず固定し、
 * その後ろに +1 で足す。
 */
var extraPolicyDefs = [
  {
    policyDefinitionId: notAllowedResourceTypesPolicyDefinitionId
    policyDefinitionReferenceId: 'denyResourceTypes-publicip'
    parameters: {
      listOfResourceTypesNotAllowed: {
        value: deniedResourceTypes
      }
      effect: {
        value: notAllowedResourceTypesEffect
      }
    }
  }
]

/**
 * v1 の並びを固定（この順序が重要）
 */
var policyDefsV1 = concat(basePolicyDefs, resourceTagPolicyDefs, rgTagPolicyDefs)

/**
 * v1.1 で末尾に追加
 */
var policyDefsV1_1 = concat(policyDefsV1, extraPolicyDefs)

resource baselinePolicySet 'Microsoft.Authorization/policySetDefinitions@2025-03-01' = {
  name: 'ps-platform-baseline-v1'
  properties: {
    displayName: 'Platform Baseline v1'
    policyType: 'Custom'
    description: 'Baseline guardrails for platform landing zone (subscription scope).'

    // PolicySetDefinition の version は変更禁止（上げるとデプロイ失敗するため固定）
    version: '1.0.0'

    // 運用上の版管理は metadata に寄せる（これは更新可能）
    metadata: {
      baselineVersion: '1.1.0'
      changeNote: 'Add deny public IP via Not allowed resource types.'
    }

    policyDefinitions: policyDefsV1_1
  }
}

resource baselineAssignment 'Microsoft.Authorization/policyAssignments@2022-06-01' = {
  name: 'pa-platform-baseline-v1'
  properties: {
    displayName: 'Platform Baseline v1 (subscription)'
    policyDefinitionId: baselinePolicySet.id
  }
}
