# Key Vault baseline v1 - Verification Evidence

## 1. Key Vault configuration (Network / RBAC / Tags / Protection)

Command:
```powershell
$KV_NAME="kvplatbaselinedev001"
az keyvault show -n $KV_NAME -g rg-platform-baseline -o jsonc
```

Output:
```json
{
  "id": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001",
  "location": "japaneast",
  "name": "kvplatbaselinedev001",
  "properties": {
    "accessPolicies": [],
    "createMode": null,
    "enablePurgeProtection": true,
    "enableRbacAuthorization": true,
    "enableSoftDelete": true,
    "enabledForDeployment": false,
    "enabledForDiskEncryption": null,
    "enabledForTemplateDeployment": null,
    "hsmPoolResourceId": null,
    "networkAcls": {
      "bypass": "AzureServices",
      "defaultAction": "Deny",
      "ipRules": [],
      "virtualNetworkRules": []
    },
    "privateEndpointConnections": null,
    "provisioningState": "Succeeded",
    "publicNetworkAccess": "Disabled",
    "sku": {
      "family": "A",
      "name": "standard"
    },
    "softDeleteRetentionInDays": 90,
    "tenantId": "0cac0579-b904-40f5-ba88-9384967c64fb",
    "vaultUri": "https://kvplatbaselinedev001.vault.azure.net/"
  },
  "resourceGroup": "rg-platform-baseline",
  "systemData": {
    "createdAt": "2026-02-03T12:18:06.947000+00:00",
    "createdBy": "avd@ryosukemwebengoutlook.onmicrosoft.com",
    "createdByType": "User",
    "lastModifiedAt": "2026-02-03T12:18:06.947000+00:00",
    "lastModifiedBy": "avd@ryosukemwebengoutlook.onmicrosoft.com",
    "lastModifiedByType": "User"
  },
  "tags": {
    "CostCenter": "cc-000",
    "Environment": "dev",
    "Owner": "ryosuke"
  },
  "type": "Microsoft.KeyVault/vaults"
}
```

Verification points (from output):
- `publicNetworkAccess`: `Disabled`
- `networkAcls.defaultAction`: `Deny`
- `enableRbacAuthorization`: `true` and `accessPolicies: []`
- `enablePurgeProtection`: `true`
- `softDeleteRetentionInDays`: `90`
- Required tags exist: `Owner`, `CostCenter`, `Environment`

---

## 2. Diagnostic settings verification (AuditEvent -> Log Analytics)

Prerequisite (KV resourceId):
```powershell
$KV_ID = az keyvault show -n $KV_NAME -g rg-platform-baseline --query id -o tsv
```

Command:
```powershell
az monitor diagnostic-settings show --name ds-kv-to-law --resource $KV_ID -o jsonc
```

Output:
```json
{
  "id": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourcegroups/rg-platform-baseline/providers/microsoft.keyvault/vaults/kvplatbaselinedev001/providers/microsoft.insights/diagnosticSettings/ds-kv-to-law",
  "logAnalyticsDestinationType": "AzureDiagnostics",
  "logs": [
    {
      "category": "AuditEvent",
      "enabled": true,
      "retentionPolicy": {
        "days": 0,
        "enabled": false
      }
    },
    {
      "category": "AzurePolicyEvaluationDetails",
      "enabled": false,
      "retentionPolicy": {
        "days": 0,
        "enabled": false
      }
    }
  ],
  "metrics": [
    {
      "category": "AllMetrics",
      "enabled": false,
      "retentionPolicy": {
        "days": 0,
        "enabled": false
      }
    }
  ],
  "name": "ds-kv-to-law",
  "resourceGroup": "rg-platform-baseline",
  "type": "Microsoft.Insights/diagnosticSettings",
  "workspaceId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-monitoring/providers/Microsoft.OperationalInsights/workspaces/law-platform-baseline"
}
```

Verification points (from output):
- Diagnostic setting name: `ds-kv-to-law`
- `logs` includes `AuditEvent` with `enabled: true`
- `metrics` includes `AllMetrics` with `enabled: false`
- `workspaceId` points to `law-platform-baseline` in `rg-platform-monitoring`

---

## 3. RBAC verification (scope = Key Vault)

### 3.1 ObjectId evidence (Entra ID)
Commands:
```powershell
$ADMIN_UPN="admin@ryosukemwebengoutlook.onmicrosoft.com"
$AVD_UPN="avd@ryosukemwebengoutlook.onmicrosoft.com"

$ADMIN_OID = az ad user show --id $ADMIN_UPN --query id -o tsv
$AVD_OID   = az ad user show --id $AVD_UPN   --query id -o tsv
```

Outputs:
```text
admin ObjectId: 3ee0f878-cfc8-49e5-b012-d4d5499f6042
avd   ObjectId: eeb850f4-8f4c-4daf-a2f2-99cbab6e8184
```

### 3.2 Role assignments list (table)
Command:
```powershell
az role assignment list --scope $KV_ID -o table
```

Output:
```text
Principal                                    Role                       Scope
-------------------------------------------  -------------------------  ------------------------------------------------------------------------------------------------------------------------------------------------
admin@ryosukemwebengoutlook.onmicrosoft.com  Key Vault Administrator    /subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001
admin@ryosukemwebengoutlook.onmicrosoft.com  Key Vault Secrets Officer  /subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001
avd@ryosukemwebengoutlook.onmicrosoft.com    Key Vault Secrets User     /subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001
```

### 3.3 Role assignments list (jsonc)
Command:
```powershell
az role assignment list --scope $KV_ID -o jsonc
```

Output:
```json
[
  {
    "condition": null,
    "conditionVersion": null,
    "createdBy": "eeb850f4-8f4c-4daf-a2f2-99cbab6e8184",
    "createdOn": "2026-02-03T12:23:32.928197+00:00",
    "delegatedManagedIdentityResourceId": null,
    "description": null,
    "id": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001/providers/Microsoft.Authorization/roleAssignments/00c6b261-543f-4ce4-8e59-a334d601386f",
    "name": "00c6b261-543f-4ce4-8e59-a334d601386f",
    "principalId": "3ee0f878-cfc8-49e5-b012-d4d5499f6042",
    "principalName": "admin@ryosukemwebengoutlook.onmicrosoft.com",
    "principalType": "User",
    "resourceGroup": "rg-platform-baseline",
    "roleDefinitionId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/roleDefinitions/00482a5a-887f-4fb3-b363-3b7fe8e74483",
    "roleDefinitionName": "Key Vault Administrator",
    "scope": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001",
    "type": "Microsoft.Authorization/roleAssignments",
    "updatedBy": "eeb850f4-8f4c-4daf-a2f2-99cbab6e8184",
    "updatedOn": "2026-02-03T12:23:32.928197+00:00"
  },
  {
    "condition": null,
    "conditionVersion": null,
    "createdBy": "eeb850f4-8f4c-4daf-a2f2-99cbab6e8184",
    "createdOn": "2026-02-03T12:23:37.815672+00:00",
    "delegatedManagedIdentityResourceId": null,
    "description": null,
    "id": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001/providers/Microsoft.Authorization/roleAssignments/adb8d9cd-646e-4c86-b813-d264ab4c1b60",
    "name": "adb8d9cd-646e-4c86-b813-d264ab4c1b60",
    "principalId": "3ee0f878-cfc8-49e5-b012-d4d5499f6042",
    "principalName": "admin@ryosukemwebengoutlook.onmicrosoft.com",
    "principalType": "User",
    "resourceGroup": "rg-platform-baseline",
    "roleDefinitionId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/roleDefinitions/b86a8fe4-44ce-4948-aee5-eccb2c155cd7",
    "roleDefinitionName": "Key Vault Secrets Officer",
    "scope": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001",
    "type": "Microsoft.Authorization/roleAssignments",
    "updatedBy": "eeb850f4-8f4c-4daf-a2f2-99cbab6e8184",
    "updatedOn": "2026-02-03T12:23:37.815672+00:00"
  },
  {
    "condition": null,
    "conditionVersion": null,
    "createdBy": "eeb850f4-8f4c-4daf-a2f2-99cbab6e8184",
    "createdOn": "2026-02-03T12:23:46.907164+00:00",
    "delegatedManagedIdentityResourceId": null,
    "description": null,
    "id": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001/providers/Microsoft.Authorization/roleAssignments/28854b60-ab1e-494c-88ec-a58ccf5a6f13",
    "name": "28854b60-ab1e-494c-88ec-a58ccf5a6f13",
    "principalId": "eeb850f4-8f4c-4daf-a2f2-99cbab6e8184",
    "principalName": "avd@ryosukemwebengoutlook.onmicrosoft.com",
    "principalType": "User",
    "resourceGroup": "rg-platform-baseline",
    "roleDefinitionId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/providers/Microsoft.Authorization/roleDefinitions/4633458b-17de-408a-b874-0445c86b69e6",
    "roleDefinitionName": "Key Vault Secrets User",
    "scope": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kvplatbaselinedev001",
    "type": "Microsoft.Authorization/roleAssignments",
    "updatedBy": "eeb850f4-8f4c-4daf-a2f2-99cbab6e8184",
    "updatedOn": "2026-02-03T12:23:46.907164+00:00"
  }
]
```
