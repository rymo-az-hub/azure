# Key Vault baseline v1 Evidence

- Date: 2026-02-07
- Subscription: 45bddcd7-c7d9-4492-b899-31f78c4cf368
- Resource Group: rg-platform-baseline
- Key Vault: kv-plat-dev-45bddcd7-001
- Private Endpoint: pe-kv-plat-dev-45bddcd7-001
- Private DNS Zone: privatelink.vaultcore.azure.net
- Log Analytics Workspace: law-platform-baseline

---

## 1. Deployment result (IaC apply)

- Scope: `rg-platform-baseline`
- Template: `infra/kv/baseline-v1/main.bicep`
- Mode: Incremental
- ProvisioningState: **Succeeded**
- Duration: **PT1M28.3340634S** (about 1m 28s)

Deployed resources (outputResources):
- `Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001`
- `Microsoft.Insights/diagnosticSettings/diag-to-law`
- `Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net`
- `Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net/virtualNetworkLinks/link-36h5a552dhzk4`
- `Microsoft.Network/privateEndpoints/pe-kv-plat-dev-45bddcd7-001`
- `Microsoft.Network/privateEndpoints/pe-kv-plat-dev-45bddcd7-001/privateDnsZoneGroups/default`

---

## 2. Key Vault baseline settings (network / authz / protection)

Command:

```powershell
az keyvault show -n kv-plat-dev-45bddcd7-001 -g rg-platform-baseline `
  --query "{publicNetworkAccess:properties.publicNetworkAccess, enableRbacAuthorization:properties.enableRbacAuthorization, softDeleteRetentionInDays:properties.softDeleteRetentionInDays, enablePurgeProtection:properties.enablePurgeProtection}" -o jsonc
```

Result:

```json
{
  "enablePurgeProtection": true,
  "enableRbacAuthorization": true,
  "publicNetworkAccess": "Disabled",
  "softDeleteRetentionInDays": 90
}
```

Expected (baseline):
- `publicNetworkAccess` = `Disabled` (Private Endpoint only)
- `enableRbacAuthorization` = `true` (RBAC model)
- `softDeleteRetentionInDays` = `90`
- `enablePurgeProtection` = `true`

---

## 3. Diagnostic settings -> Log Analytics

Key Vault resource id:

```text
/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001
```

Command:

```powershell
az monitor diagnostic-settings list --resource $kvId -o jsonc
```

Result:

```json
[
  {
    "id": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourcegroups/rg-platform-baseline/providers/microsoft.keyvault/vaults/kv-plat-dev-45bddcd7-001/providers/microsoft.insights/diagnosticSettings/diag-to-law",
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
    "name": "diag-to-law",
    "resourceGroup": "rg-platform-baseline",
    "type": "Microsoft.Insights/diagnosticSettings",
    "workspaceId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.OperationalInsights/workspaces/law-platform-baseline"
  }
]
```

Expected (baseline):
- `diag-to-law` exists
- `workspaceId` points to `law-platform-baseline`
- `AuditEvent` enabled = `true`
- metrics `AllMetrics` enabled = `false`

Note:
- `AzurePolicyEvaluationDetails` appears as an available category (disabled). This is acceptable.

---

## 4. Private Endpoint connection state

Command:

```powershell
az network private-endpoint show -n pe-kv-plat-dev-45bddcd7-001 -g rg-platform-baseline `
  --query "{name:name, provisioningState:provisioningState, subnet:subnet.id, connectionStatus:privateLinkServiceConnections[0].privateLinkServiceConnectionState.status, privateLinkServiceId:privateLinkServiceConnections[0].privateLinkServiceId, nicId:networkInterfaces[0].id}" -o jsonc
```

Result:

```json
{
  "connectionStatus": "Approved",
  "name": "pe-kv-plat-dev-45bddcd7-001",
  "nicId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.Network/networkInterfaces/pe-kv-plat-dev-45bddcd7-001.nic.ef9ebc5c-3716-4d36-aa84-e96249f7ef04",
  "privateLinkServiceId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.KeyVault/vaults/kv-plat-dev-45bddcd7-001",
  "provisioningState": "Succeeded",
  "subnet": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-network-baseline/providers/Microsoft.Network/virtualNetworks/vnet-platform-baseline/subnets/snet-privatelink"
}
```

Expected (baseline):
- `provisioningState` = `Succeeded`
- `connectionStatus` = `Approved`
- `subnet` is the dedicated privatelink subnet
- `privateLinkServiceId` points to the Key Vault
- `nicId` exists

---

## 5. Private DNS Zone Group binding

Command:

```powershell
az network private-endpoint dns-zone-group show `
  -g rg-platform-baseline `
  --endpoint-name pe-kv-plat-dev-45bddcd7-001 `
  -n default -o jsonc
```

Result:

```json
{
  "etag": "W/\"994f5173-3e15-4768-bd5a-df7dc27567f7\"",
  "id": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.Network/privateEndpoints/pe-kv-plat-dev-45bddcd7-001/privateDnsZoneGroups/default",
  "name": "default",
  "privateDnsZoneConfigs": [
    {
      "name": "kv-dns",
      "privateDnsZoneId": "/subscriptions/45bddcd7-c7d9-4492-b899-31f78c4cf368/resourceGroups/rg-platform-baseline/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net",
      "recordSets": [
        {
          "fqdn": "kv-plat-dev-45bddcd7-001.privatelink.vaultcore.azure.net",
          "ipAddresses": [
            "10.10.1.4"
          ],
          "provisioningState": "Succeeded",
          "recordSetName": "kv-plat-dev-45bddcd7-001",
          "recordType": "A",
          "ttl": 10
        }
      ]
    }
  ],
  "provisioningState": "Succeeded",
  "resourceGroup": "rg-platform-baseline"
}
```

Expected (baseline):
- zone group `default` provisioningState = `Succeeded`
- `privateDnsZoneId` points to `privatelink.vaultcore.azure.net`
- A record exists for the Key Vault FQDN and resolves to the PE IP (`10.10.1.4`)

---
