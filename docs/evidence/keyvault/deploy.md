# Key Vault baseline v1 - Deploy Evidence

## 1. Subscription
Configured:
- Subscription name: Sub-Azure  
- Subscription id: `45bddcd7-c7d9-4492-b899-31f78c4cf368`

(Reference command)
```powershell
az account show --query "{name:name,id:id}" -o json
```

---

## 2. Resource Group creation

### 2.1 Failure evidence (Policy deny: required RG tags)

Attempt (no tags specified at first):
```powershell
az group create -n rg-platform-baseline -l japaneast -o table
```

Result (failure):
```text
(RequestDisallowedByPolicy) Resource 'rg-platform-baseline' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"Platform Baseline v1 (subscription)","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1"},"policyDefinition":{"name":"Require a tag on resource groups","id":"/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025","version":"1.0.0"},"policySetDefinition":{"name":"Platform Baseline v1","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1","version":"1.0.0"}},{"policyAssignment":{"name":"Platform Baseline v1 (subscription)","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1"},"policyDefinition":{"name":"Require a tag on resource groups","id":"/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025","version":"1.0.0"},"policySetDefinition":{"name":"Platform Baseline v1","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1","version":"1.0.0"}},{"policyAssignment":{"name":"Platform Baseline v1 (subscription)","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1"},"policyDefinition":{"name":"Require a tag on resource groups","id":"/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025","version":"1.0.0"},"policySetDefinition":{"name":"Platform Baseline v1","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1","version":"1.0.0"}}]'.
Code: RequestDisallowedByPolicy
Message: Resource 'rg-platform-baseline' was disallowed by policy. Policy identifiers: '[{"policyAssignment":{"name":"Platform Baseline v1 (subscription)","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1"},"policyDefinition":{"name":"Require a tag on resource groups","id":"/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025","version":"1.0.0"},"policySetDefinition":{"name":"Platform Baseline v1","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1","version":"1.0.0"}},{"policyAssignment":{"name":"Platform Baseline v1 (subscription)","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1"},"policyDefinition":{"name":"Require a tag on resource groups","id":"/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025","version":"1.0.0"},"policySetDefinition":{"name":"Platform Baseline v1","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1","version":"1.0.0"}},{"policyAssignment":{"name":"Platform Baseline v1 (subscription)","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1"},"policyDefinition":{"name":"Require a tag on resource groups","id":"/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025","version":"1.0.0"},"policySetDefinition":{"name":"Platform Baseline v1","id":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1","version":"1.0.0"}}]'.
Target: rg-platform-baseline
Additional Information:Type: PolicyViolation
Info: {
    "evaluationDetails": {
        "evaluatedExpressions": [
            {
                "result": "True",
                "expressionKind": "Field",
                "expression": "type",
                "path": "type",
                "expressionValue": "Microsoft.Resources/subscriptions/resourcegroups",
                "targetValue": "Microsoft.Resources/subscriptions/resourceGroups",
                "operator": "Equals"
            },
            {
                "result": "True",
                "expressionKind": "Field",
                "expression": "tags[Owner]",
                "path": "tags[Owner]",
                "targetValue": "false",
                "operator": "Exists"
            }
        ]
    },
    "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025",
    "policySetDefinitionId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1",
    "policyDefinitionReferenceId": "requireRgTag-owner",
    "policySetDefinitionName": "ps-platform-baseline-v1",
    "policySetDefinitionDisplayName": "Platform Baseline v1",
    "policySetDefinitionVersion": "1.0.0",
    "policyDefinitionName": "96670d01-0a4d-4649-9c89-2d3abc0a5025",
    "policyDefinitionDisplayName": "Require a tag on resource groups",
    "policyDefinitionVersion": "1.0.0",
    "policyDefinitionEffect": "deny",
    "policyAssignmentId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1",
    "policyAssignmentName": "pa-platform-baseline-v1",
    "policyAssignmentDisplayName": "Platform Baseline v1 (subscription)",
    "policyAssignmentScope": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368",
    "policyAssignmentParameters": {},
    "policyExemptionIds": [],
    "policyEnrollmentIds": []
}Type: PolicyViolation
Info: {
    "evaluationDetails": {
        "evaluatedExpressions": [
            {
                "result": "True",
                "expressionKind": "Field",
                "expression": "type",
                "path": "type",
                "expressionValue": "Microsoft.Resources/subscriptions/resourcegroups",
                "targetValue": "Microsoft.Resources/subscriptions/resourceGroups",
                "operator": "Equals"
            },
            {
                "result": "True",
                "expressionKind": "Field",
                "expression": "tags[CostCenter]",
                "path": "tags[CostCenter]",
                "targetValue": "false",
                "operator": "Exists"
            }
        ]
    },
    "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025",
    "policySetDefinitionId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1",
    "policyDefinitionReferenceId": "requireRgTag-costcenter",
    "policySetDefinitionName": "ps-platform-baseline-v1",
    "policySetDefinitionDisplayName": "Platform Baseline v1",
    "policySetDefinitionVersion": "1.0.0",
    "policyDefinitionName": "96670d01-0a4d-4649-9c89-2d3abc0a5025",
    "policyDefinitionDisplayName": "Require a tag on resource groups",
    "policyDefinitionVersion": "1.0.0",
    "policyDefinitionEffect": "deny",
    "policyAssignmentId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1",
    "policyAssignmentName": "pa-platform-baseline-v1",
    "policyAssignmentDisplayName": "Platform Baseline v1 (subscription)",
    "policyAssignmentScope": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368",
    "policyAssignmentParameters": {},
    "policyExemptionIds": [],
    "policyEnrollmentIds": []
}Type: PolicyViolation
Info: {
    "evaluationDetails": {
        "evaluatedExpressions": [
            {
                "result": "True",
                "expressionKind": "Field",
                "expression": "type",
                "path": "type",
                "expressionValue": "Microsoft.Resources/subscriptions/resourcegroups",
                "targetValue": "Microsoft.Resources/subscriptions/resourceGroups",
                "operator": "Equals"
            },
            {
                "result": "True",
                "expressionKind": "Field",
                "expression": "tags[Environment]",
                "path": "tags[Environment]",
                "targetValue": "false",
                "operator": "Exists"
            }
        ]
    },
    "policyDefinitionId": "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025",
    "policySetDefinitionId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policySetDefinitions/ps-platform-baseline-v1",
    "policyDefinitionReferenceId": "requireRgTag-environment",
    "policySetDefinitionName": "ps-platform-baseline-v1",
    "policySetDefinitionDisplayName": "Platform Baseline v1",
    "policySetDefinitionVersion": "1.0.0",
    "policyDefinitionName": "96670d01-0a4d-4649-9c89-2d3abc0a5025",
    "policyDefinitionDisplayName": "Require a tag on resource groups",
    "policyDefinitionVersion": "1.0.0",
    "policyDefinitionEffect": "deny",
    "policyAssignmentId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/policyAssignments/pa-platform-baseline-v1",
    "policyAssignmentName": "pa-platform-baseline-v1",
    "policyAssignmentDisplayName": "Platform Baseline v1 (subscription)",
    "policyAssignmentScope": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368",
    "policyAssignmentParameters": {},
    "policyExemptionIds": [],
    "policyEnrollmentIds": []
}
```

Root cause:
- Policy set `Platform Baseline v1` enforces required tags on **resource groups**.
- Missing required tags: `Owner`, `CostCenter`, `Environment` (effect: `deny`).

### 2.2 Fix evidence (create RG with required tags)

Command (example values):
```powershell
az group create -n rg-platform-baseline -l japaneast --tags Owner=ryosuke CostCenter=cc-000 Environment=dev -o table
```

Validation:
```powershell
az group show -n rg-platform-baseline --query "{name:name,location:location,tags:tags}" -o jsonc
```

Output:
```json
{
  "location": "japaneast",
  "name": "rg-platform-baseline",
  "tags": {
    "CostCenter": "cc-000",
    "Environment": "dev",
    "Owner": "ryosuke"
  }
}
```

---

## 3. Log Analytics Workspace existence (Diagnostics prerequisite)

Command:
```powershell
az monitor log-analytics workspace show -g rg-platform-monitoring -n law-platform-baseline -o table
```

Output:
```text
CreatedDate                   CustomerId                            Location    ModifiedDate                  Name                   ProvisioningState    PublicNetworkAccessForIngestion    PublicNetworkAccessForQuery    ResourceGroup           RetentionInDays
----------------------------  ------------------------------------  ----------  ----------------------------  ---------------------  -------------------  ---------------------------------  -----------------------------  ----------------------  -----------------
2026-02-01T11:37:07.2083648Z  57e13f7a-fab0-4e0d-9e6c-7fbd1309ad7e  japaneast   2026-02-01T12:07:45.9076867Z  law-platform-baseline  Succeeded            Enabled                            Enabled                        rg-platform-monitoring  30
```

---

## 4. what-if result (Key Vault + Diagnostic Settings)
#縺薙ｌ縺ｯ蜻ｽ蜷堺ｿｮ豁｣蜑阪・ what-if
Command:
```powershell
az deployment group what-if `
  -g rg-platform-baseline `
  -f ./infra/keyvault/main.bicep `
  -p ./infra/keyvault/kv.dev.parameters.json
```

Output:
```text
Note: The result may contain false positive predictions (noise).

Resource and property changes are indicated with this symbol:
  + Create

The deployment will update the following scope:
Scope: /subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline

  + Microsoft.KeyVault/vaults/kv-platform-baseline-dev-001 [2023-07-01]
      location:                             "japaneast"
      name:                                 "kv-platform-baseline-dev-001"
      properties.enablePurgeProtection:     true
      properties.enableRbacAuthorization:   true
      properties.networkAcls.bypass:        "AzureServices"
      properties.networkAcls.defaultAction: "Deny"
      properties.publicNetworkAccess:       "Disabled"
      properties.sku.name:                  "standard"
      properties.softDeleteRetentionInDays: 90
      tags.CostCenter:                      "cc-000"
      tags.Environment:                     "dev"
      tags.Owner:                           "ryosuke"

  + Microsoft.KeyVault/vaults/kv-platform-baseline-dev-001/providers/Microsoft.Insights/diagnosticSettings/ds-kv-to-law [2021-05-01-preview]
      name:                   "ds-kv-to-law"
      properties.logs:
        - category: "AuditEvent"
          enabled:  true
      properties.metrics:
        - category: "AllMetrics"
          enabled:  false
      properties.workspaceId: "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-platform-baseline"

Resource changes: 2 to create.
```

---

## 5. Deployment failure & fix (Key Vault naming rule)

### 5.1 Failure (first attempt)
Command:
```powershell
az deployment group create `
  -g rg-platform-baseline `
  -f ./infra/keyvault/main.bicep `
  -p ./infra/keyvault/kv.dev.parameters.json `
  -o table
```

Result (failure):
```text
{"status":"Failed","error":{"code":"DeploymentFailed","target":"/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.Resources/deployments/main","message":"At least one resource deployment operation failed. Please list deployment operations for details. Please see https://aka.ms/arm-deployment-operations for usage details.","details":[{"code":"VaultNameNotValid","message":"The vault name 'kv-platform-baseline-dev-001' is invalid. A vault's name must be between 3-24 alphanumeric characters. The name must begin with a letter, end with a letter or digit, and not contain consecutive hyphens. Follow this link for more information: https://go.microsoft.com/fwlink/?linkid=2147742"}]}}
```

Root cause:
- Key Vault name rule: **3窶・4 characters, alphanumeric only**.
- Hyphens (`-`) are not allowed for Key Vault resource name.

### 5.2 Fix
- Updated Key Vault name to an alphanumeric-only name (3窶・4 chars):
  - `kvplatbaselinedev001`

---

## 6. Deployment result (success)

Result:
```text
Name    State      Timestamp                         Mode         ResourceGroup
------  ---------  --------------------------------  -----------  --------------------
main    Succeeded  2026-02-03T12:18:27.573689+00:00  Incremental  rg-platform-baseline
```
